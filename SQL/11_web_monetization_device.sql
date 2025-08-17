SELECT
	deviceCategory,
	COUNT(DISTINCT unique_session_id) AS sessions,
	((COUNT(DISTINCT unique_session_id)/SUM(COUNT(DISTINCT unique_session_id)) OVER ())*100) AS sessions_percentage,
	SUM(transactionrevenue)/1e6 AS revenue,
	((SUM(transactionrevenue)/SUM(SUM(transactionrevenue)) OVER ())*100) AS revenue_percentage
FROM (
	SELECT
		deviceCategory,
		transactionrevenue,
		CONCAT(fullvisitorid, '-', visitid) AS unique_session_id
	FROM gms_project.data_combined
	GROUP BY 1,2,3
) t1
GROUP BY 1;