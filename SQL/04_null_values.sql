SELECT 
    COUNT(*) AS total_rows,
    COUNT(visitid) AS non_null_rows
FROM gms_project.data_combined;