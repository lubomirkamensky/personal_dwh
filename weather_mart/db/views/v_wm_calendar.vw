CREATE VIEW pdwh_mart_weather.v_wm_calendar AS
SELECT
    DATE_FORMAT(wm.`Datetime`, '%Y%m%d%H') AS Hour_id
    ,DATE_FORMAT(wm.`Datetime`, '%Y%m%d') AS Day_id
    ,DATE_FORMAT(wm.`Datetime`, '%Y%m') AS Month_id
FROM
    pdwh_detail.weather_measuring wm
GROUP BY 1,2,3;