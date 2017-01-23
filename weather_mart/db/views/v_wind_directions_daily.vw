CREATE VIEW pdwh_mart_weather.v_wind_directions_daily AS
SELECT
    DATE_FORMAT(wm.`Datetime`, '%Y%m%d') AS Day_id
    ,CASE WHEN wm.Wind_Speed > 0 THEN wm.Wind_Direction ELSE NULL END AS Wind_Direction
    ,MIN(wm.Wind_Speed) AS Wind_Speed_MIN
    ,MAX(wm.Wind_Speed) AS Wind_Speed_MAX
    ,AVG(wm.Wind_Speed) AS Wind_Speed_AVG
    ,Count(*) AS Records_count
FROM
    pdwh_detail.weather_measuring wm
INNER JOIN
    pdwh_mart_weather.t_process_day lm
    ON DATE_FORMAT(wm.`Datetime`, '%Y%m%d') = lm.Day_Id
GROUP BY 1,2;
