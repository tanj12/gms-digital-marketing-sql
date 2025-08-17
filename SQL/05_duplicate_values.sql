SELECT
	visitid,
	COUNT(*) as total_rows
FROM gms_project.data_combined
GROUP BY 1
HAVING COUNT(*) > 1
LIMIT 5;