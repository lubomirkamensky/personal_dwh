CREATE OR REPLACE VIEW pdwh_mart_astronomical.v_firebase_hourly AS
SELECT 
     m.Hour_Id
     ,CONCAT(Substr(m.Hour_Id,1,4),'-',Substr(m.Hour_Id,5,2),'-',Substr(m.Hour_Id,7,2),' ',Substr(m.Hour_Id,9,2)) AS Hour_Val
     ,m.Daylight_Length
FROM 
     pdwh_mart_astronomical.v_daylight_length_hourly m
JOIN 
     pdwh_mart_astronomical.v_load_range r 
     ON m.Hour_Id = r.Hour_Id 
;