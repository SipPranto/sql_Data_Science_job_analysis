use projects;
select * from sal limit 10;
select work_year from salaries;
/*1.You're a Compensation analyst employed by a multinational corporation. Your Assignment is to Pinpoint Countries who give work fully remotely, for the title
 'managers’ Paying salaries Exceeding $90,000 USD*/
 
SELECT distinct(company_location) FROM sal WHERE job_title like '%Manager%' and salary_IN_usd > 90000 and remote_ratio= 100;

/*2.AS a remote work advocate Working for a progressive HR tech startup who place their freshers’ clients IN large tech firms. you're tasked WITH 
Identifying top 5 Country Having  greatest count of large(company size) number of companies.*/

SELECT company_location, COUNT(company_size) AS 'cnt' 
FROM (
    SELECT * FROM sal WHERE experience_level ='EN' AND company_size='L'
) AS t  
GROUP BY company_location 
ORDER BY cnt DESC
LIMIT 5;


/*3. Picture yourself AS a data scientist Working for a workforce management platform. Your objective is to calculate the percentage of employees. 
Who enjoy fully remote roles WITH salaries Exceeding $100,000 USD, Shedding light ON the attractiveness of high-paying remote positions IN today's job market.*/
set @COUNT= (SELECT COUNT(*) FROM sal  WHERE salary_IN_usd >100000 and remote_ratio=100);
set @total = (SELECT COUNT(*) FROM sal where salary_in_usd>100000);
set @percentage= round((((SELECT @COUNT)/(SELECT @total))*100),2);
SELECT @percentage AS '%  of people workINg remotly and havINg salary >100,000 USD';


/*4.	Imagine you're a data analyst Working for a global recruitment agency. Your Task is to identify the Locations where entry-level average salaries exceed the 
average salary for that job title in market for entry level, helping your agency guide candidates towards lucrative countries.*/
SELECT company_location, t.job_title, average_per_country, average FROM 
(
	SELECT company_location,job_title,AVG(salary_IN_usd) AS average_per_country FROM  sal WHERE experience_level = 'EN' 
	GROUP BY  company_locatiON, job_title
) AS t 
INNER JOIN 
( 
	 SELECT job_title,AVG(salary_IN_usd) AS average FROM  sal  WHERE experience_level = 'EN'  GROUP BY job_title
) AS p 
ON  t.job_title = p.job_title WHERE average_per_country> average




/*5. You've been hired by a big HR Consultancy to look at how much people get paid IN different Countries. Your job is to Find out for each job title which
Country pays the maximum average salary. This helps you to place your candidates IN those countries.*/


SELECT company_location, job_title , average FROM
(
SELECT *, dense_rank() over (partitiON by job_title order by average desc)  AS num FROM 
(
SELECT company_location, job_title , AVG(salary_IN_usd) AS 'average' FROM sal GROUP BY company_locatiON, job_title
)k
)t  WHERE num=1


/*6.  AS a data-driven Business consultant, you've been hired by a multinational corporation to analyze salary trends across different company Locations.
 Your goal is to Pinpoint Locations WHERE the average salary Has consistently Increased over the Past few years (Countries WHERE data is available for 3 years Only(this and pst two years) 
 providing Insights into Locations experiencing Sustained salary growth.*/

WITH t AS
(
 SELECT * FROM  sal WHERE company_location IN
		(
			SELECT company_location FROM
			(
				SELECT company_location, AVG(salary_IN_usd) AS AVG_salary,COUNT(DISTINCT work_year) AS num_years FROM sal WHERE work_year >= YEAR(CURRENT_DATE()) - 2
				GROUP BY  company_location HAVING  num_years = 3 
			)m
		)

)

-- SELECT company_location, work_year, AVG(salary_IN_usd) AS average FROM  t GROUP BY company_location, work_year 


SELECT 
    company_location,
    MAX(CASE WHEN work_year = 2022 THEN  average END) AS AVG_salary_2022,
    MAX(CASE WHEN work_year = 2023 THEN average END) AS AVG_salary_2023,
    MAX(CASE WHEN work_year = 2024 THEN average END) AS AVG_salary_2024
FROM 
(SELECT company_location, work_year, AVG(salary_IN_usd) AS average FROM  t GROUP BY company_location, work_year )q
GROUP BY company_location  having AVG_salary_2024 > AVG_salary_2023 AND AVG_salary_2023 > AVG_salary_2022




/*salary compare for remote job for 2021 and 2024 */

WITH e AS
(
select experience_level,work_year,avg(salary_in_usd) as average
from
(select * from sal where remote_ratio=100 and work_year in(2021,2024)) t
group by experience_level,work_year
order by experience_level
)

select *,
case 
	when avg_2021<avg_2024 then 'increase'
    ELSE 'declining' end
as 'comment'
from 
(select experience_level,
max(case when work_year=2021 then average end) as avg_2021,
max(case when work_year=2024 then average end) as avg_2024
from e
group by experience_level) k



 /* 7.	Picture yourself AS a workforce strategist employed by a global HR tech startup. Your missiON is to determINe the percentage of  fully remote work for each 
 experience level IN 2021 and compare it WITH the correspONdINg figures for 2024, highlightINg any significant INcreASes or decreASes IN remote work adoptiON
 over the years.*/



WITH pc AS(
select rm.experience_level,rm.work_year,rm.remote_worker,al.all_worker
from
(
(select experience_level,work_year,count(*)as remote_worker
from
(select * from sal where remote_ratio=100 and work_year in(2021,2024)) t
group by experience_level,work_year
order by experience_level) rm
join
(select experience_level,work_year,count(*)as all_worker
from
(select * from sal  where work_year in(2021,2024)) p
group by experience_level,work_year
order by experience_level) al
on rm.experience_level=al.experience_level
and rm.work_year=al.work_year
)
)


select experience_level, 
max(case when work_year=2021 then remote_pct end) as remote_pct_2021,
max(case when work_year=2024 then remote_pct end) as remote_pct_2024
from
(select * ,((remote_worker/all_worker)*100) as remote_pct from pc
order by experience_level,work_year) d
group by experience_level;

























