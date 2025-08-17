
SELECT 
    DAYNAME(date) AS weekday,
    COUNT(DISTINCT unique_session_id) AS sessions,
    SUM(converted) AS conversions,
	((SUM(converted)/COUNT(DISTINCT unique_session_id))*100) AS conversion_rate
FROM (
	SELECT
		DATE(FROM_UNIXTIME(date)) AS date,
        CASE
			WHEN transactions >= 1 THEN 1
			ELSE 0 
		END AS converted,
        CONCAT(fullvisitorid, '-', visitid) AS unique_session_id
    FROM gms_project.data_combined
    GROUP BY 1,2,3
) t1
GROUP BY 1
ORDER BY 2 DESC;
