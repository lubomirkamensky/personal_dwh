DROP PROCEDURE IF EXISTS pdwh_detail.delete_astro_devents_in_scope;
DELIMITER $$
CREATE PROCEDURE pdwh_detail.delete_astro_devents_in_scope()
BEGIN
DELETE a FROM pdwh_detail.event a
CROSS JOIN
     pdwh_detail.v_event_astro_scope_year b
WHERE 
     Subject_Id IN (2) AND Event_Type_Id IN (7,8,9,10) AND YEAR(Event_Start_Dt) BETWEEN b.From_year AND b.Till_Year;
DELETE a FROM pdwh_detail.event a
CROSS JOIN
     pdwh_detail.v_event_astro_scope_day b
WHERE 
     Subject_Id IN (1,2) AND Event_Type_Id IN (1,2,3,4,5,6) AND DATE_FORMAT(Event_Start_Dt, '%Y%m%d')   BETWEEN b.From_Day AND b.Till_Day;
END$$
DELIMITER ;