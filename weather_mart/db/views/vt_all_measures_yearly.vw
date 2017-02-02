CREATE VIEW pdwh_mart_weather.vt_all_measures_yearly AS
SELECT
  LEFT(Month_id, 4) AS Year_Id,
  SUM(Actual_Rain) AS Actual_Rain,
  MIN(Relative_Pressure_MIN) AS Relative_Pressure_MIN,
  MAX(Relative_Pressure_MAX) AS Relative_Pressure_MAX,
  AVG(Relative_Pressure_AVG) AS Relative_Pressure_AVG,
  MIN(Outdoor_Temp_MIN) AS Outdoor_Temp_MIN,
  MAX(Outdoor_Temp_MAX) AS Outdoor_Temp_MAX,
  AVG(Outdoor_Temp_AVG) AS Outdoor_Temp_AVG,
  MIN(Outdoor_Hum_MIN) AS Outdoor_Hum_MIN,
  MAX(Outdoor_Hum_MAX) AS Outdoor_Hum_MAX,
  AVG(Outdoor_Hum_AVG) AS Outdoor_Hum_AVG,
  MIN(Dewpoint_MIN) AS Dewpoint_MIN,
  MAX(Dewpoint_MAX) AS Dewpoint_MAX,
  AVG(Dewpoint_AVG) AS Dewpoint_AVG,
  MIN(Wind_Speed_MIN) AS Wind_Speed_MIN,
  MAX(Wind_Speed_MAX) AS Wind_Speed_MAX,
  AVG(Wind_Speed_AVG) AS Wind_Speed_AVG,
  SUM(Records_count) AS Records_count
FROM pdwh_mart_weather.vt_all_measures_monthly
GROUP BY 1
;