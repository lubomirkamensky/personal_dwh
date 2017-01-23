CREATE VIEW pdwh_mart_weather.v_month_range AS
SELECT
    LEFT(CAST(Hour_id AS CHAR),6) AS Month_id
FROM
    pdwh_mart_weather.t_wm_calendar
WHERE 
    hour_id NOT IN (SELECT hour_id from pdwh_mart_weather.t_loaded_hour) 
UNION
SELECT
    LEFT(CAST(Day_id AS CHAR),6) AS Month_id
FROM
    pdwh_mart_weather.t_wm_calendar
WHERE 
    Day_id NOT IN (SELECT Day_id from pdwh_mart_weather.t_loaded_day) 
UNION
SELECT
    Month_id
FROM
    pdwh_mart_weather.t_wm_calendar
WHERE 
    Month_id NOT IN (SELECT Month_id from pdwh_mart_weather.t_loaded_month) 
;
