CREATE VIEW pdwh_mart_weather.v_actual_month AS
SELECT 
CASE WHEN DATE_FORMAT(current_date, '%e') = 1 THEN DATE_FORMAT(subdate(current_date, 1), '%Y%m') ELSE DATE_FORMAT(current_date, '%Y%m') END AS Month_Id
;