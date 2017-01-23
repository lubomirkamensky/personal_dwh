CREATE VIEW pdwh_mart_weather.v_process_month AS
SELECT
    Month_id
FROM
    pdwh_mart_weather.t_wm_calendar
WHERE 
    Month_id NOT IN (SELECT Month_id from pdwh_mart_weather.t_loaded_month) 
    AND Month_id <= CASE WHEN DATE_FORMAT(current_date, '%e') = 1 THEN DATE_FORMAT(subdate(current_date, 1), '%Y%m') ELSE DATE_FORMAT(current_date, '%Y%m') END 
GROUP BY 1
;