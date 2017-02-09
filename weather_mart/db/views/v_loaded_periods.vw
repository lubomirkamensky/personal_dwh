CREATE OR REPLACE VIEW pdwh_mart_weather.v_loaded_periods AS
    SELECT 
        MAX(DATE_FORMAT(wm.`Datetime`, '%Y%m%d')) AS Day_id
    FROM
        pdwh_detail.weather_measuring wm
    INNER JOIN
        pdwh_mart_weather.t_loaded_periods tm
        ON DATE_FORMAT(wm.`Datetime`, '%Y%m%d') >= tm.Day_Id
;
