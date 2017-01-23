CREATE DEFINER=`root`@`%` PROCEDURE `load_all`()
BEGIN
  DECLARE actual_month INT;
  DECLARE done BOOLEAN DEFAULT FALSE;
  DECLARE v_month INT;
  DECLARE cur1 CURSOR FOR SELECT month_id FROM t_month_range;
  DECLARE CONTINUE HANDLER FOR NOT FOUND SET done = TRUE;

  delete from t_wm_calendar;
  insert into t_wm_calendar select * from v_wm_calendar;
  
  delete from t_all_measures_yearly;
  delete from t_wind_directions_yearly;

  select Month_Id into actual_month from v_actual_month; 
  delete from t_all_measures_monthly where month_id = actual_month;
  delete from t_wind_directions_monthly where month_id = actual_month;
  delete from t_loaded_month where month_id = actual_month;

  delete from t_month_range;
  insert into t_month_range select * from v_month_range;

  OPEN cur1;

  read_loop: LOOP
    FETCH cur1 INTO v_month;
    IF done THEN
      LEAVE read_loop;
    END IF;
    delete from t_process_hour;
    insert into t_process_hour select Hour_Id from v_process_hour where month_id = v_month;
    delete from t_process_day;
    insert into t_process_day select Day_Id from v_process_day where month_id = v_month;
    delete from t_process_month;
    insert into t_process_month select Month_Id from v_process_month where month_id = v_month;
    
    insert into t_all_measures_hourly select * from v_all_measures_hourly;
    insert into t_wind_directions_hourly select * from v_wind_directions_hourly;
    insert into t_all_measures_daily select * from v_all_measures_daily;
    insert into t_wind_directions_daily select * from v_wind_directions_daily;
    insert into t_all_measures_monthly select * from v_all_measures_monthly;
    insert into t_wind_directions_monthly select * from v_wind_directions_monthly;
    
    insert into t_loaded_hour select * from t_process_hour;
    insert into t_loaded_day select * from t_process_day;
    insert into t_loaded_month select * from t_process_month;

  END LOOP;
  CLOSE cur1;
  insert into t_all_measures_yearly select * from v_all_measures_yearly;
  insert into t_wind_directions_yearly select * from v_wind_directions_yearly;
END