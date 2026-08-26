WITH remote_jobs AS (
    SELECT skills_job_dim.skill_id,
        COUNT(jpc.job_id) AS jobs_count
    FROM job_postings_fact jpc
        INNER JOIN skills_job_dim ON skills_job_dim.job_id = jpc.job_id
    WHERE jpc.job_work_from_home = true
        AND jpc.job_title_short = 'Data Analyst'
    GROUP BY skills_job_dim.skill_id
)
SELECT skills_dim.skills,
    remote_jobs.jobs_count
FROM skills_dim
    INNER JOIN remote_jobs ON remote_jobs.skill_id = skills_dim.skill_id
ORDER BY remote_jobs.jobs_count DESC
LIMIT 5;
/*
 Identify the top 5 skills that are most frequently mentioned in job postings. 
 Use a subquery to find the skill IDs with the highest counts in the skills_job_dim table and then join this result with the skills_dim table to get the skill names.
 */
WITH skills_to_job AS (
    SELECT skill_id,
        COUNT(job_id) AS jobs_count
    FROM skills_job_dim
    GROUP BY skill_id
)
SELECT skills_dim.skills,
    skills_to_job.jobs_count
FROM skills_dim
    INNER JOIN skills_to_job ON skills_dim.skill_id = skills_to_job.skill_id
ORDER BY jobs_count DESC
LIMIT 5;
/* 
 
 Determine the size category ('Small', 'Medium', or 'Large') for each company by first identifying the number of job postings they have. 
 Use a subquery to calculate the total job postings per company. A company is considered 'Small' if it has less than 10 job postings, 
 'Medium' if the number of job postings is between 10 and 50, 
 and 'Large' if it has more than 50 job postings. 
 Implement a subquery to aggregate job counts per company before classifying them based on size.
 
 */
SELECT company_id,
    company_name,
    jobs_count,
    CASE
        WHEN jobs_count < 10 THEN 'Small'
        WHEN jobs_count BETWEEN 10 AND 50 THEN 'Medium'
        ELSE 'Large'
    END AS company_size
FROM (
        SELECT company_dim.company_id AS company_id,
            company_dim.name AS company_name,
            COUNT(job_postings_fact.job_id) AS jobs_count
        FROM company_dim
            INNER JOIN job_postings_fact ON job_postings_fact.company_id = company_dim.company_id
        GROUP BY company_dim.company_id,
            company_dim.name
    )
ORDER BY company_id;
/*
 Your goal is to find the names of companies that have an average salary greater than the overall average salary across all job postings.
 
 You'll need to use two tables: company_dim (for company names) and job_postings_fact (for salary data). The solution requires using subqueries.
 */

SELECT 
    company_dim.name, 
    avg_salary_company.company_avg_salary
FROM company_dim
    INNER JOIN (
        SELECT jpc.company_id,
            AVG(salary_year_avg) AS company_avg_salary
        FROM job_postings_fact AS jpc
        GROUP BY jpc.company_id
) AS avg_salary_company ON company_dim.company_id = avg_salary_company.company_id
WHERE avg_salary_company.company_avg_salary > (
    SELECT AVG(salary_year_avg) AS ovr_avg_salary
    FROM job_postings_fact
)