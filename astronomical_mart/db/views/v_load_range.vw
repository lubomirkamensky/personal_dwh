CREATE OR REPLACE VIEW pdwh_mart_astronomical.v_load_range AS
SELECT
    Hour_Id 
FROM
     pdwh_detail.hour h
INNER JOIN
     pdwh_mart_astronomical.v_load_scope s
     ON h.hour_id >  s.Min_Hour_Id 
       AND h.hour_id <=  s.Max_Hour_Id
ORDER BY  Hour_Id 
LIMIT 600 
; 