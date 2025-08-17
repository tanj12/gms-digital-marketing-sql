SELECT
	CASE
		WHEN newVisits = 1 THEN 'New Visitor'
		ELSE 'Returning Visitor'
	END AS visitor_type,
	COUNT(DISTINCT fullVisitorId) AS visitors,
    ((COUNT(DISTINCT fullVisitorId)/SUM(COUNT(DISTINCT fullVisitorId)) OVER ())*100) AS visitors_percentage
FROM gms_project.data_combined
GROUP BY 1;
