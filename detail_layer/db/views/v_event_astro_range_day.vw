CREATE OR REPLACE VIEW pdwh_detail.v_event_astro_range_day AS
SELECT
     CONCAT(Substr(Day_Id,5,2),'/',Substr(Day_Id,7,2),'/',Substr(Day_Id,1,4)) as Day
     ,Day_Id
     ,CONCAT(Substr(Day_Id,1,4),'-',Substr(Day_Id,5,2),'-',Substr(Day_Id,7,2)) as Day_Dt
FROM 
     pdwh_detail.day a
CROSS JOIN
     pdwh_detail.v_event_astro_scope_day b
WHERE Day_Id > b.From_Day AND Day_Id <= b.Till_Day
;


