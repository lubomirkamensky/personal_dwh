Set cn = CreateObject("ADODB.Connection")
cn.Open  "dsn=personal_dwh;uid=root;pwd=securemarc"

cn.execute("delete from t_wm_calendar")
cn.execute("insert into t_wm_calendar select * from v_wm_calendar")

cn.execute("delete from t_hour_detail")
cn.execute("insert into t_hour_detail select a.* from v_hour_detail a inner join t_wm_calendar b on a.hour_id = b.hour_id")

cn.execute("delete from t_all_measures_yearly")
cn.execute("delete from t_wind_directions_yearly")

set tasks0 = cn.execute("select Month_Id from v_actual_month")
If not tasks0.eof then
	Do while not tasks0.eof
    cn.execute("delete from t_all_measures_monthly where month_id =" & tasks0("Month_Id"))
    cn.execute("delete from t_wind_directions_monthly where month_id =" & tasks0("Month_Id"))
    cn.execute("delete from t_loaded_month where month_id =" & tasks0("Month_Id"))
		tasks0.movenext
	Loop
End If 

cn.execute("delete from t_month_range")
cn.execute("insert into t_month_range select * from v_month_range")

set tasks = cn.execute("select Month_Id from t_month_range")
If not tasks.eof then
	Do while not tasks.eof
    cn.execute("delete from t_process_hour")
    cn.execute("insert into t_process_hour select Hour_Id from v_process_hour where month_id =" & tasks("Month_Id"))
    cn.execute("delete from t_process_day")
    cn.execute("insert into t_process_day select Day_Id from v_process_day where month_id =" & tasks("Month_Id"))
    cn.execute("delete from t_process_month")
    cn.execute("insert into t_process_month select Month_Id from v_process_month where month_id =" & tasks("Month_Id"))
    
    cn.execute("insert into t_all_measures_hourly select * from v_all_measures_hourly")
    cn.execute("insert into t_wind_directions_hourly select * from v_wind_directions_hourly")

    cn.execute("insert into t_all_measures_daily select * from v_all_measures_daily")
    cn.execute("insert into t_wind_directions_daily select * from v_wind_directions_daily")
    
    cn.execute("insert into t_all_measures_monthly select * from v_all_measures_monthly")
    cn.execute("insert into t_wind_directions_monthly select * from v_wind_directions_monthly")

    cn.execute("insert into t_loaded_hour select * from t_process_hour")
    cn.execute("insert into t_loaded_day select * from t_process_day")
    cn.execute("insert into t_loaded_month select * from t_process_month")
    
		tasks.movenext
	Loop
End If 

cn.execute("insert into t_all_measures_yearly select * from v_all_measures_yearly")
cn.execute("insert into t_wind_directions_yearly select * from v_wind_directions_yearly")

WScript.Quit