CREATE VIEW pdwh_mart_weather.v_wind_directions_yearly AS
SELECT
    DATE_FORMAT(wm.`Datetime`, '%Y') AS Year_id
    ,CASE WHEN wm.Wind_Speed > 0 THEN wm.Wind_Direction ELSE NULL END AS Wind_Direction
    ,MIN(wm.Wind_Speed) AS Wind_Speed_MIN
    ,MAX(wm.Wind_Speed) AS Wind_Speed_MAX
    ,AVG(wm.Wind_Speed) AS Wind_Speed_AVG
    ,Count(*) AS Records_count
FROM
    pdwh_detail.weather_measuring wm
GROUP BY 1,2;
