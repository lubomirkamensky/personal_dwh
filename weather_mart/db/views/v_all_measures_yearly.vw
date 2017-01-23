CREATE VIEW pdwh_mart_weather.v_all_measures_yearly AS
SELECT
    m.Year_id AS Year_id
    ,SUM(wm.Actual_Rain) AS Actual_Rain
    ,MIN(wm.Relative_Pressure_MIN) AS Relative_Pressure_MIN
    ,MAX(wm.Relative_Pressure_MAX) AS Relative_Pressure_MAX
    ,AVG(wm.Relative_Pressure_AVG) AS Relative_Pressure_AVG
    ,MIN(wm.Outdoor_Temp_MIN) AS Outdoor_Temp_MIN
    ,MAX(wm.Outdoor_Temp_MAX) AS Outdoor_Temp_MAX
    ,AVG(wm.Outdoor_Temp_AVG) AS Outdoor_Temp_AVG
    ,MIN(wm.Outdoor_Hum_MIN) AS Outdoor_Hum_MIN
    ,MAX(wm.Outdoor_Hum_MAX) AS Outdoor_Hum_MAX
    ,AVG(wm.Outdoor_Hum_AVG) AS Outdoor_Hum_AVG
    ,MIN(wm.Dewpoint_MIN) AS Dewpoint_MIN
    ,MAX(wm.Dewpoint_MAX) AS Dewpoint_MAX
    ,AVG(wm.Dewpoint_AVG) AS Dewpoint_AVG
    ,MIN(wm.Wind_Speed_MIN) AS Wind_Speed_MIN
    ,MAX(wm.Wind_Speed_MAX) AS Wind_Speed_MAX
    ,AVG(wm.Wind_Speed_AVG) AS Wind_Speed_AVG
    ,SUM(wm.Records_count) AS Records_count
FROM
    pdwh_mart_weather.t_all_measures_monthly wm
INNER JOIN
    pdwh_detail.`month` m
    ON wm.Month_id = m.Month_id
GROUP BY 1
;
