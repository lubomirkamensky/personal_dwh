CREATE OR REPLACE VIEW pdwh_mart_weather.vs_all_measures_daily4day AS
SELECT
  Day_id,
  SUM(Actual_Rain) AS Actual_Rain,
  SUM(Relative_Pressure_MIN) AS Relative_Pressure_MIN,
  SUM(Relative_Pressure_MAX) AS Relative_Pressure_MAX,
  SUM(Relative_Pressure_AVG) AS Relative_Pressure_AVG,
  SUM(Outdoor_Temp_MIN) AS Outdoor_Temp_MIN,
  SUM(Outdoor_Temp_MAX) AS Outdoor_Temp_MAX,
  SUM(Outdoor_Temp_AVG) AS Outdoor_Temp_AVG,
  SUM(Outdoor_Hum_MIN) AS Outdoor_Hum_MIN,
  SUM(Outdoor_Hum_MAX) AS Outdoor_Hum_MAX,
  SUM(Outdoor_Hum_AVG) AS Outdoor_Hum_AVG,
  SUM(Dewpoint_MIN) AS Dewpoint_MIN,
  SUM(Dewpoint_MAX) AS Dewpoint_MAX,
  SUM(Dewpoint_AVG) AS Dewpoint_AVG,
  SUM(Wind_Speed_MIN) AS Wind_Speed_MIN,
  SUM(Wind_Speed_MAX) AS Wind_Speed_MAX,
  SUM(Wind_Speed_AVG) AS Wind_Speed_AVG,
  SUM(Records_count) AS Records_count
FROM pdwh_mart_weather.va_all_measures_daily4day
GROUP BY 1
;