CREATE VIEW pdwh_mart_weather.v_process_day AS
SELECT
    Day_id
    ,LEFT(CAST(Day_id AS CHAR),6) AS Month_id
FROM
    pdwh_mart_weather.t_wm_calendar
WHERE 
    day_id NOT IN (SELECT day_id from pdwh_mart_weather.t_loaded_day) 
    AND day_id < DATE_FORMAT(current_date, '%Y%m%d')
GROUP BY 1,2
;
