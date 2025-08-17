SELECT 
    DAYNAME(date) AS weekday,
    COUNT(DISTINCT unique_session_id) AS sessions
FROM (
	SELECT
		DATE(FROM_UNIXTIME(date)) AS date,
        CONCAT(fullvisitorid, '-', visitid) AS unique_session_id
    FROM gms_project.data_combined
    GROUP BY 1,2
) t1
GROUP BY 1
ORDER BY 2 DESC;