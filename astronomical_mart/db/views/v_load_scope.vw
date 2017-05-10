CREATE OR REPLACE VIEW pdwh_mart_astronomical.v_load_scope AS
SELECT
     MAX(A.Max_Hour_Id) AS Min_Hour_Id
     ,MIN(Hour_Id) AS Max_Hour_Id
FROM
     pdwh_detail.hour
CROSS JOIN
     (SELECT 
           MAX(Hour_Id) AS Max_Hour_Id
      FROM
           pdwh_mart_astronomical.t_loaded_periods
      ) A
WHERE
     SUBSTR(Hour_Id,5,6) = '123123'  AND Hour_Id > A.Max_Hour_Id AND Hour_Id < YEAR(now()) * 1000000 + 123124 
;