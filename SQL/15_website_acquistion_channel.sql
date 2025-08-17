SELECT
	channelGrouping,
	COUNT(DISTINCT unique_session_id) AS sessions,
	SUM(bounces) AS bounces,
	((SUM(bounces)/COUNT(DISTINCT unique_session_id))*100) AS bounce_rate
FROM (
	SELECT
		channelGrouping,
		bounces,
		CONCAT(fullvisitorid, '-', visitid) AS unique_session_id
	FROM gms_project.data_combined
	GROUP BY 1,2,3
) t1
GROUP BY 1
ORDER BY 2 DESC;