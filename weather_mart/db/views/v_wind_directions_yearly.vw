CREATE VIEW pdwh_mart_weather.v_wind_directions_yearly AS
SELECT
    m.Year_id AS Year_id
    ,wm.Wind_Direction
    ,MIN(wm.Wind_Speed_MIN) AS Wind_Speed_MIN
    ,MAX(wm.Wind_Speed_MAX) AS Wind_Speed_MAX
    ,AVG(wm.Wind_Speed_AVG) AS Wind_Speed_AVG
    ,SUM(Records_count) AS Records_count
FROM
    pdwh_mart_weather.t_wind_directions_monthly wm
INNER JOIN
    pdwh_detail.`Month` m
    ON wm.Month_id = m.Month_id
GROUP BY 1,2;
;
