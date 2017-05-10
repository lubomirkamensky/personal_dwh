CREATE OR REPLACE VIEW pdwh_detail.v_event_astro_scope_day AS
SELECT 
     COALESCE(MAX(DATE_FORMAT(Event_Start_Dt, '%Y%m%d')),20110701) AS From_Day,
     YEAR(now())*10000+1231 as Till_Day
FROM
     pdwh_detail.event 
WHERE
     Subject_Id = 2 and Event_Type_Id = 2 
;