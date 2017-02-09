DROP PROCEDURE IF EXISTS pdwh_mart_weather.sp_load_actual_rain;
DELIMITER $$
CREATE PROCEDURE pdwh_mart_weather.sp_load_actual_rain()
BEGIN
DECLARE max_time datetime;
DECLARE last_total_rain decimal(7,1);
DECLARE v_time datetime;
DECLARE v_total_rain decimal(7,1);
DECLARE done BOOLEAN DEFAULT FALSE;
DECLARE cur1 CURSOR FOR SELECT `Datetime`, Total_Rain 
FROM pdwh_detail.weather_measuring WHERE `Datetime` > max_time ORDER BY `Datetime`;
DECLARE CONTINUE HANDLER FOR NOT FOUND SET done = TRUE;

SET max_time := (SELECT COALESCE(MAX(`Datetime`),'2000-01-01 00:00:00') AS max_time FROM pdwh_mart_weather.t_actual_rain);

SET last_total_rain := (SELECT Total_Rain FROM pdwh_detail.weather_measuring WHERE `Datetime` = max_time);

  OPEN cur1;

  read_loop: LOOP
    FETCH cur1 INTO v_time,v_total_rain;
    IF done THEN
      LEAVE read_loop;
    END IF;
    insert into pdwh_mart_weather.t_actual_rain 
    values(v_time,v_total_rain-COALESCE(last_total_rain,v_total_rain));
    SET last_total_rain := v_total_rain;

  END LOOP;
  CLOSE cur1;

END$$
DELIMITER ;
