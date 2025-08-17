SELECT
	CONCAT(fullvisitorid, '-', visitid) AS unique_session_id,
	FROM_UNIXTIME(date) - INTERVAL 8 HOUR AS date,
	COUNT(*) as total_rows
FROM gms_project.data_combined
GROUP BY 1,2
HAVING unique_session_id = "4961200072408009421-1480578925"
LIMIT 5;