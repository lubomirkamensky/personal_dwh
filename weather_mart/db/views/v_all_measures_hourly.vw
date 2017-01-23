CREATE VIEW pdwh_mart_weather.v_all_measures_hourly AS
SELECT
    DATE_FORMAT(wm.`Datetime`, '%Y%m%d%H') AS Hour_id
    ,MAX(wm.Total_Rain) - MIN(wm.Total_Rain) AS Actual_Rain
    ,MIN(wm.Relative_Pressure) AS Relative_Pressure_MIN
    ,MAX(wm.Relative_Pressure) AS Relative_Pressure_MAX
    ,AVG(wm.Relative_Pressure) AS Relative_Pressure_AVG
    ,MIN(wm.Outdoor_Temp) AS Outdoor_Temp_MIN
    ,MAX(wm.Outdoor_Temp) AS Outdoor_Temp_MAX
    ,AVG(wm.Outdoor_Temp) AS Outdoor_Temp_AVG
    ,MIN(wm.Outdoor_Hum) AS Outdoor_Hum_MIN
    ,MAX(wm.Outdoor_Hum) AS Outdoor_Hum_MAX
    ,AVG(wm.Outdoor_Hum) AS Outdoor_Hum_AVG
    ,MIN(wm.Dewpoint) AS Dewpoint_MIN
    ,MAX(wm.Dewpoint) AS Dewpoint_MAX
    ,AVG(wm.Dewpoint) AS Dewpoint_AVG
    ,MIN(wm.Wind_Speed) AS Wind_Speed_MIN
    ,MAX(wm.Wind_Speed) AS Wind_Speed_MAX
    ,AVG(wm.Wind_Speed) AS Wind_Speed_AVG
    ,Count(*) AS Records_count
FROM
    pdwh_detail.weather_measuring wm
INNER JOIN
    pdwh_mart_weather.t_process_hour lm
    ON DATE_FORMAT(wm.`Datetime`, '%Y%m%d%H') = lm.Hour_Id
GROUP BY 1;
