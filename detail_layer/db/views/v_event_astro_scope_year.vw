CREATE OR REPLACE VIEW pdwh_detail.v_event_astro_scope_year AS
SELECT
     COALESCE(MAX(Year(Event_Start_Dt)),2011) AS From_Year,
     YEAR(now()) as Till_Year
FROM
     pdwh_detail.event 
WHERE
     Subject_Id = 2 and Event_Type_Id = 7
;