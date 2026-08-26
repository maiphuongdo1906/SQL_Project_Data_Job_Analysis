WITH wfh_jobs (
    SELECT 
        job_id, 
        COUNT(*) AS jobs_count
    FROM
        job_postings_fact
    WHERE
        job_work_from_home = true
    GROUP BY
        job_id
)
SELECT 
    
