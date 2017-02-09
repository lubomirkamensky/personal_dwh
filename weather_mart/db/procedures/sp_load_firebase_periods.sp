DROP PROCEDURE IF EXISTS pdwh_mart_weather.sp_load_firebase_periods;
DELIMITER $$
CREATE PROCEDURE pdwh_mart_weather.sp_load_firebase_periods()
BEGIN
UPDATE pdwh_mart_weather.t_loaded_periods dest, pdwh_mart_weather.v_loaded_periods src SET dest.Day_Id = src.Day_Id;
END$$
DELIMITER ;


