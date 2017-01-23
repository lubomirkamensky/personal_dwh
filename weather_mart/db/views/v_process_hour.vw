CREATE VIEW pdwh_mart_weather.v_process_hour AS
SELECT
    Hour_id
    ,LEFT(CAST(Hour_id AS CHAR),6) AS Month_id
FROM
    pdwh_mart_weather.t_wm_calendar
WHERE 
    hour_id NOT IN (SELECT hour_id from pdwh_mart_weather.t_loaded_hour) 
    AND hour_id < DATE_FORMAT(current_date, '%Y%m%d%H')  
GROUP BY 1
;
