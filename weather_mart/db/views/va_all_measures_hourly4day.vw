CREATE OR REPLACE VIEW pdwh_mart_weather.va_all_measures_hourly4day AS
SELECT
  Hour_id,
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
    pdwh_mart_weather.v_all_measures_hourly4day
UNION ALL
SELECT
  adj.Hour_id,
  adj.Actual_Rain,
  adj.Relative_Pressure_MIN,
  adj.Relative_Pressure_MAX,
  adj.Relative_Pressure_AVG,
  adj.Outdoor_Temp_MIN,
  adj.Outdoor_Temp_MAX,
  adj.Outdoor_Temp_AVG,
  adj.Outdoor_Hum_MIN,
  adj.Outdoor_Hum_MAX,
  adj.Outdoor_Hum_AVG,
  adj.Dewpoint_MIN,
  adj.Dewpoint_MAX,
  adj.Dewpoint_AVG,
  adj.Wind_Speed_MIN,
  adj.Wind_Speed_MAX,
  adj.Wind_Speed_AVG,
  adj.Records_count
FROM
    pdwh_mart_weather.t_adj_all_measures_hourly adj
INNER JOIN
    pdwh_mart_weather.t_loaded_periods tm
    ON adj.Hour_id >= tm.Day_Id*100;