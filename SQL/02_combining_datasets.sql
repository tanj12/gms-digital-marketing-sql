CREATE TABLE gms_project.data_combined AS (

	SELECT * FROM gms_project.data_10

	UNION ALL 

	SELECT * FROM gms_project.data_11

	UNION ALL

	SELECT * FROM gms_project.data_12

);