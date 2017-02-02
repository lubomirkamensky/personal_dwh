CREATE VIEW pdwh_mart_weather.vtu_all_measures_monthly AS
SELECT
  Month_id,
  Actual_Rain,
  Relative_Pressure_MIN,
  Relative_Pressure_MAX,
  Relative_Pressure_AVG,
  Outdoor_Temp_MIN,
  Outdoor_Temp_MAX,
  Outdoor_Temp_AVG,
  Outdoor_Hum_MIN,
  Outdoor_Hum_MAX,
  Outdoor_Hum_AVG,
  Dewpoint_MIN,
  Dewpoint_MAX,
  Dewpoint_AVG,
  Wind_Speed_MIN,
  Wind_Speed_MAX,
  Wind_Speed_AVG,
  Records_count
FROM
    pdwh_mart_weather.v_all_measures_monthly
UNION ALL
SELECT
  Month_id,
  Actual_Rain,
  Relative_Pressure_MIN,
  Relative_Pressure_MAX,
  Relative_Pressure_AVG,
  Outdoor_Temp_MIN,
  Outdoor_Temp_MAX,
  Outdoor_Temp_AVG,
  Outdoor_Hum_MIN,
  Outdoor_Hum_MAX,
  Outdoor_Hum_AVG,
  Dewpoint_MIN,
  Dewpoint_MAX,
  Dewpoint_AVG,
  Wind_Speed_MIN,
  Wind_Speed_MAX,
  Wind_Speed_AVG,
  Records_count
FROM
    pdwh_mart_weather.t_adj_all_measures_monthly
UNION ALL
SELECT
  LEFT(Day_id, 6) AS Month_id,
  SUM(Actual_Rain),
  SUM(Relative_Pressure_MIN),
  SUM(Relative_Pressure_MAX),
  SUM(Relative_Pressure_AVG),
  SUM(Outdoor_Temp_MIN),
  SUM(Outdoor_Temp_MAX),
  SUM(Outdoor_Temp_AVG),
  SUM(Outdoor_Hum_MIN),
  SUM(Outdoor_Hum_MAX),
  SUM(Outdoor_Hum_AVG),
  SUM(Dewpoint_MIN),
  SUM(Dewpoint_MAX),
  SUM(Dewpoint_AVG),
  SUM(Wind_Speed_MIN),
  SUM(Wind_Speed_MAX),
  SUM(Wind_Speed_AVG),
  SUM(Records_count)
FROM
    pdwh_mart_weather.t_adj_all_measures_daily md
GROUP BY 1
UNION ALL
SELECT
  LEFT(hour_id, 6) AS Month_id,
  SUM(Actual_Rain),
  SUM(Relative_Pressure_MIN),
  SUM(Relative_Pressure_MAX),
  SUM(Relative_Pressure_AVG),
  SUM(Outdoor_Temp_MIN),
  SUM(Outdoor_Temp_MAX),
  SUM(Outdoor_Temp_AVG),
  SUM(Outdoor_Hum_MIN),
  SUM(Outdoor_Hum_MAX),
  SUM(Outdoor_Hum_AVG),
  SUM(Dewpoint_MIN),
  SUM(Dewpoint_MAX),
  SUM(Dewpoint_AVG),
  SUM(Wind_Speed_MIN),
  SUM(Wind_Speed_MAX),
  SUM(Wind_Speed_AVG),
  SUM(Records_count)
FROM
    pdwh_mart_weather.t_adj_all_measures_hourly
GROUP BY 1       
;