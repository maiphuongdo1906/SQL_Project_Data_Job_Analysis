/*
 Identify companies with the most diverse (unique) job titles.
 Use a CTE to count the number of unique job titles per company, then select companies with the highest diversity in job titles.
 */
WITH companies_unique_jobs AS (
    SELECT company_id,
        COUNT(DISTINCT job_title) AS num_unique_jobs
    FROM job_postings_fact
    GROUP BY company_id
)
SELECT name,
    companies_unique_jobs.num_unique_jobs
FROM company_dim
    INNER JOIN companies_unique_jobs ON company_dim.company_id = companies_unique_jobs.company_id
ORDER BY num_unique_jobs DESC;
/*
 Explore job postings by listing job id, job titles, company names, and their average salary rates, while categorizing these salaries relative to the average in their respective countries. 
 Include the month of the job posted date. Use CTEs, conditional logic, and date functions, to compare individual salaries with national averages.
 */
WITH country_avg_salary AS (
    SELECT job_country,
        AVG(salary_year_avg) AS country_salary_rate
    FROM job_postings_fact
    GROUP BY job_country
)
SELECT job_id,
    job_title,
    company_dim.name,
    salary_year_avg AS salary_rate,
    CASE
        WHEN salary_year_avg > country_avg_salary.country_salary_rate THEN 'Above Average'
        ELSE 'Below Average'
    END AS salary_category,
    EXTRACT(
        MONTH
        FROM job_posted_date
    ) AS posting_month
FROM job_postings_fact
    INNER JOIN company_dim ON job_postings_fact.company_id = company_dim.company_id
    INNER JOIN country_avg_salary ON job_postings_fact.job_country = country_avg_salary.job_country
ORDER BY posting_month DESC;

/*
Your goal is to calculate two metrics for each company:

The number of unique skills required for their job postings.

The highest average annual salary among job postings that require at least one skill.

Your final query should return the company name, the count of unique skills, and the highest salary. For companies with no skill-related job postings, the skill count should be 0 and the salary should be null.

*/
WITH required_skills AS (
    SELECT 
        company_dim.company_id,
        COUNT(DISTINCT skills_job_dim.skill_id) AS unique_skills
    FROM company_dim
        LEFT JOIN job_postings_fact AS jpc ON jpc.company_id = company_dim.company_id
        LEFT JOIN skills_job_dim ON skills_job_dim.job_id = jpc.job_id
    GROUP BY company_dim.company_id
), 
max_salary AS(
    SELECT 
        company_id,
        MAX(salary_year_avg) AS highest_salary
    FROM job_postings_fact
    WHERE job_id IN (SELECT job_id FROM skills_job_dim)
    GROUP BY company_id
    )
SELECT 
    name AS company_name, 
    required_skills.unique_skills,
    max_salary.highest_salary
FROM company_dim
    LEFT JOIN required_skills ON required_skills.company_id = company_dim.company_id
    LEFT JOIN max_salary ON max_salary.company_id = company_dim.company_id
ORDER BY company_name