SELECT
		deviceCategory,
		region,
		COUNT(DISTINCT unique_session_id) AS sessions,
    ((COUNT(DISTINCT unique_session_id)/SUM(COUNT(DISTINCT unique_session_id)) OVER ())*100) AS sessions_percentage,
		SUM(transactionrevenue)/1e6 AS revenue,
    ((SUM(transactionrevenue)/SUM(SUM(transactionrevenue)) OVER ())*100) AS revenue_percentage
FROM (
		SELECT
				deviceCategory,
        CASE
						WHEN region = '' OR region IS NULL THEN 'NA'
						ELSE region
				END AS region,
				transactionrevenue,
				CONCAT(fullvisitorid, '-', visitid) AS unique_session_id
		FROM gms_project.data_combined
		WHERE deviceCategory = "mobile"
		GROUP BY 1,2,3,4
) t1
GROUP BY 1,2
ORDER BY 3 DESC;