SELECT
	channelGrouping,
	COUNT(DISTINCT unique_session_id) AS sessions,
	SUM(bounces) AS bounces,
	((SUM(bounces)/COUNT(DISTINCT unique_session_id))*100) AS bounce_rate,
    (SUM(pageviews)/COUNT(DISTINCT unique_session_id)) AS avg_pagesonsite,
    (SUM(timeonsite)/COUNT(DISTINCT unique_session_id)) AS avg_timeonsite,
	SUM(CASE WHEN transactions >= 1 THEN 1 ELSE 0 END) AS conversions,
    ((SUM(CASE WHEN transactions >= 1 THEN 1 ELSE 0 END)/COUNT(DISTINCT unique_session_id))*100) AS conversion_rate,
	SUM(transactionrevenue)/1e6 AS revenue
FROM (
	SELECT
		channelGrouping,
        bounces,
        pageviews,
        timeonsite,
        transactions,
        transactionrevenue,
		CONCAT(fullvisitorid, '-', visitid) AS unique_session_id
	FROM gms_project.data_combined
	GROUP BY 1,2,3,4,5,6,7
) t1
GROUP BY 1
ORDER BY 2 DESC;