WITH first_quarter_job AS(
    SELECT *
    FROM january_jobs
    UNION ALL
    SELECT *
    FROM february_jobs
    UNION ALL
    SELECT *
    FROM march_jobs
)
SELECT job_title_short, 
    job_location,
    job_via,
    job_posted_date::DATE,
    salary_year_avg

FROM first_quarter_job
WHERE salary_year_avg > 70000
    AND job_title_short = 'Data Analyst'
ORDER BY salary_year_avg DESC;

(
SELECT 
    job_id,
    job_title,
    'With Salary Info' AS salary_info
FROM job_postings_fact
WHERE 
    salary_year_avg IS NOT NULL OR
    salary_hour_avg IS NOT NULL
)

UNION ALL

(
SELECT 
    job_id,
    job_title,
    'Without Salary Info' AS salary_info
FROM job_postings_fact
WHERE 
    salary_year_avg IS NULL AND
    salary_hour_avg IS NULL
)
ORDER BY job_id;

/*
Retrieve the job id, job title short, job location, job via, skill and skill type for each job posting from the first quarter (January to March). 
Using a subquery to combine job postings from the first quarter (these tables were created in the Advanced Section - Practice Problem 6 Video) Only include postings with an average yearly salary greater than $70,000.
*/

SELECT 
    first_quarter_jobs.job_id,
    job_title_short,
    job_location, 
    job_via, 
    salary_year_avg,
    skills_dim.skills,
    skills_dim.type
FROM (
    SELECT * 
    FROM january_jobs
    UNION ALL
    SELECT * 
    FROM february_jobs
    UNION ALL
    SELECT * 
    FROM march_jobs
) AS first_quarter_jobs
    LEFT JOIN skills_job_dim ON first_quarter_jobs.job_id = skills_job_dim.job_id
    LEFT JOIN skills_dim ON skills_job_dim.skill_id = skills_dim.skill_id
WHERE salary_year_avg > 70000
ORDER BY first_quarter_jobs.job_id;

/*
Analyze the monthly demand for skills by counting the number of job postings for each skill in the first quarter (January to March), 
utilizing data from separate tables for each month. Ensure to include skills from all job postings across these months. 
The tables for the first quarter job postings were created in Practice Problem 6.
*/

SELECT 
    skills_dim.skills,
    EXTRACT(YEAR FROM job_posted_date) AS year,
    EXTRACT(MONTH FROM job_posted_date) AS month,
    COUNT(first_quarter_jobs.job_id) AS jobs_count
FROM (
    SELECT * 
    FROM january_jobs
    UNION ALL
    SELECT * 
    FROM february_jobs
    UNION ALL
    SELECT * 
    FROM march_jobs
) AS first_quarter_jobs
INNER JOIN skills_job_dim ON skills_job_dim.job_id = first_quarter_jobs.job_id
INNER JOIN skills_dim ON skills_dim.skill_id = skills_job_dim.skill_id
GROUP BY
    skills_dim.skills,
    month,
    year
ORDER BY skills, year, month


