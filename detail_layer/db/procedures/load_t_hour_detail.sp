CREATE DEFINER=`root`@`%` PROCEDURE `load_t_hour_detail`()
BEGIN
delete from t_hour_detail;
insert into t_hour_detail select a.* from v_hour_detail a inner join t_wm_calendar b on a.hour_id = b.hour_id;
END