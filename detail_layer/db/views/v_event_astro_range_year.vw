CREATE OR REPLACE VIEW pdwh_detail.v_event_astro_range_year AS
SELECT 
     a.Year_Id 
FROM 
     pdwh_detail.year a
CROSS JOIN
     pdwh_detail.v_event_astro_scope_year b
WHERE 
     a.Year_Id > b.From_Year AND a.Year_Id <= b.Till_Year
;


