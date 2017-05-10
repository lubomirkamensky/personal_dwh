CREATE OR REPLACE VIEW pdwh_mart_astronomical.v_daylight_length_hourly AS
/* Sun Rise Hours */
SELECT
    DATE_FORMAT(Event_Start_Dt, '%Y%m%d%H') AS Hour_id 
    ,60-MINUTE(Event_Start_Dt) AS Daylight_Length 
FROM 
     pdwh_detail.event 
WHERE 
     Subject_Id = 1
     AND Event_Type_Id = 2
UNION ALL
/* Sun Set Hours */
SELECT
    DATE_FORMAT(Event_Start_Dt, '%Y%m%d%H') AS Hour_id 
    ,MINUTE(Event_Start_Dt) AS Daylight_Length 
FROM 
     pdwh_detail.event 
WHERE 
     Subject_Id = 1
     AND Event_Type_Id = 4
/* Hours before Sun Rise Hour*/
UNION ALL
SELECT
     a.Hour_id
     ,0 AS Daylight_Length 
FROM
	 pdwh_detail.event b
INNER JOIN
	 pdwh_detail.hour a
     ON b.Subject_Id = 1
       AND b.Event_Type_Id = 2
       AND a.Hour_Id BETWEEN  DATE_FORMAT(b.Event_Start_Dt, '%Y%m%d00') AND DATE_FORMAT(b.Event_Start_Dt, '%Y%m%d%H')-1
UNION ALL
/* Hours after Sun Set Hour */
SELECT
     a.Hour_id
     ,0 AS Daylight_Length 
FROM
     pdwh_detail.event b
INNER JOIN
	 pdwh_detail.hour a
     ON b.Subject_Id = 1
       AND b.Event_Type_Id = 4
       AND a.Hour_Id BETWEEN DATE_FORMAT(b.Event_Start_Dt, '%Y%m%d%H')+1 AND DATE_FORMAT(b.Event_Start_Dt, '%Y%m%d23')
UNION ALL
/* Hours after Sun Rise Hour and before Sun Set Hour*/
SELECT      
     c.Hour_Id 
     ,60 AS Daylight_Length
FROM      
     pdwh_detail.event a 
INNER JOIN      
     pdwh_detail.event b      
     ON a.Subject_Id = 1        
       AND a.Event_Type_Id = 2        
       AND b.Subject_Id = 1        
       AND b.Event_Type_Id = 4        
       AND DATE_FORMAT(a.Event_Start_Dt, '%Y%m%d') = DATE_FORMAT(b.Event_Start_Dt, '%Y%m%d') 
INNER JOIN      
     pdwh_detail.hour c      
     ON c.Hour_Id BETWEEN DATE_FORMAT(a.Event_Start_Dt, '%Y%m%d%H')+1  AND DATE_FORMAT(b.Event_Start_Dt, '%Y%m%d%H')-1 
;