CREATE OR REPLACE VIEW pdwh_detail.v_hour_detail AS
SELECT
    h.hour_id
    ,h.prior_hour_id
    ,h.hour_in_day
    ,h.day_id
    ,h.hour_start_dt
    ,h.hour_end_dt
    ,CASE
      WHEN h.hour_start_dt >= e.event_start_dt AND h.hour_end_dt <= e.event_end_dt THEN 1
      WHEN e.event_start_dt BETWEEN h.hour_start_dt AND h.hour_end_dt AND TIME_TO_SEC(TIMEDIFF(h.hour_end_dt,e.event_start_dt)) >= 1800 THEN 1
      WHEN e.event_end_dt BETWEEN h.hour_start_dt AND h.hour_end_dt AND TIME_TO_SEC(TIMEDIFF(e.event_end_dt,h.hour_start_dt)) >= 1800 THEN 1
      ELSE 0
     END AS light_indicator
     ,CASE
      WHEN h.hour_start_dt >= e.event_start_dt AND h.hour_end_dt <= e.event_end_dt THEN 1
      WHEN e.event_start_dt BETWEEN h.hour_start_dt AND h.hour_end_dt THEN TIME_TO_SEC(TIMEDIFF(h.hour_end_dt,e.event_start_dt))/3600
      WHEN e.event_end_dt BETWEEN h.hour_start_dt AND h.hour_end_dt THEN TIME_TO_SEC(TIMEDIFF(e.event_end_dt,h.hour_start_dt))/3600
      ELSE 0
     END AS light_lenght
     ,CASE WHEN f.event_start_dt BETWEEN h.hour_start_dt AND h.hour_end_dt THEN f.event_start_dt ELSE NULL END AS sun_rise_dt
     ,CASE WHEN f.event_end_dt BETWEEN h.hour_start_dt AND h.hour_end_dt THEN f.event_end_dt ELSE NULL END AS sun_set_dt
     ,CASE WHEN i.event_start_dt BETWEEN h.hour_start_dt AND h.hour_end_dt THEN i.event_start_dt ELSE NULL END AS moon_rise_dt
     ,CASE WHEN i.event_end_dt BETWEEN h.hour_start_dt AND h.hour_end_dt THEN i.event_end_dt ELSE NULL END AS moon_set_dt
     ,CASE WHEN e.event_start_dt BETWEEN h.hour_start_dt AND h.hour_end_dt THEN e.event_start_dt ELSE NULL END AS light_start_dt
     ,CASE WHEN e.event_end_dt BETWEEN h.hour_start_dt AND h.hour_end_dt THEN e.event_end_dt ELSE NULL END AS light_end_dt
     ,CASE WHEN j.event_end_dt IS NOT NULL THEN j.event_start_dt ELSE NULL END AS new_moon_dt
     ,CASE WHEN k.event_end_dt IS NOT NULL THEN k.event_start_dt ELSE NULL END AS fist_q_moon_dt
     ,CASE WHEN l.event_end_dt IS NOT NULL THEN l.event_start_dt ELSE NULL END AS full_moon_dt
     ,CASE WHEN m.event_end_dt IS NOT NULL THEN m.event_start_dt ELSE NULL END AS last_q_moon_dt
     ,CASE WHEN n.event_end_dt IS NOT NULL THEN n.event_start_dt ELSE NULL END AS total_solar_e_dt
     ,CASE WHEN o.event_end_dt IS NOT NULL THEN o.event_start_dt ELSE NULL END AS annual_solar_e_dt
     ,CASE WHEN p.event_end_dt IS NOT NULL THEN p.event_start_dt ELSE NULL END AS hybrid_solar_e_dt
     ,CASE WHEN q.event_end_dt IS NOT NULL THEN q.event_start_dt ELSE NULL END AS partial_solar_e_dt
     ,CASE WHEN r.event_end_dt IS NOT NULL THEN r.event_start_dt ELSE NULL END AS total_lunar_e_dt
     ,CASE WHEN s.event_end_dt IS NOT NULL THEN s.event_start_dt ELSE NULL END AS partial_lunar_e_dt
     ,CASE WHEN t.event_end_dt IS NOT NULL THEN t.event_start_dt ELSE NULL END AS penumbral_lunar_e_dt
FROM
    pdwh_detail.HOUR h
LEFT JOIN
    pdwh_detail.EVENT e
    ON h.hour_start_dt <= e.event_end_dt
      AND h.hour_end_dt >= e.event_start_dt
      AND e.event_cd = 3
LEFT JOIN
    pdwh_detail.EVENT f
    ON h.hour_start_dt <= f.event_end_dt
      AND h.hour_end_dt >= f.event_start_dt
      AND f.event_cd = 1
LEFT JOIN
    pdwh_detail.EVENT i
    ON h.hour_start_dt <= i.event_end_dt
      AND h.hour_end_dt >= i.event_start_dt
      AND i.event_cd = 2
LEFT JOIN
    pdwh_detail.EVENT j
    ON j.event_start_dt BETWEEN h.hour_start_dt AND h.hour_end_dt
      AND j.event_cd = 4
LEFT JOIN
    pdwh_detail.EVENT k
    ON k.event_start_dt BETWEEN h.hour_start_dt AND h.hour_end_dt
      AND k.event_cd = 5   
LEFT JOIN
    pdwh_detail.EVENT l
    ON l.event_start_dt BETWEEN h.hour_start_dt AND h.hour_end_dt
      AND l.event_cd = 6
LEFT JOIN
    pdwh_detail.EVENT m
    ON m.event_start_dt BETWEEN h.hour_start_dt AND h.hour_end_dt
      AND m.event_cd = 7
LEFT JOIN
    pdwh_detail.EVENT n
    ON n.event_start_dt BETWEEN h.hour_start_dt AND h.hour_end_dt
      AND n.event_cd = 8   
LEFT JOIN
    pdwh_detail.EVENT o
    ON o.event_start_dt BETWEEN h.hour_start_dt AND h.hour_end_dt
      AND o.event_cd = 9
LEFT JOIN
    pdwh_detail.EVENT p
    ON p.event_start_dt BETWEEN h.hour_start_dt AND h.hour_end_dt
      AND p.event_cd = 10
LEFT JOIN
    pdwh_detail.EVENT q
    ON q.event_start_dt BETWEEN h.hour_start_dt AND h.hour_end_dt
      AND q.event_cd = 11  
LEFT JOIN
    pdwh_detail.EVENT r
    ON r.event_start_dt BETWEEN h.hour_start_dt AND h.hour_end_dt
      AND r.event_cd = 12
LEFT JOIN
    pdwh_detail.EVENT s
    ON s.event_start_dt BETWEEN h.hour_start_dt AND h.hour_end_dt
      AND s.event_cd = 13
LEFT JOIN
    pdwh_detail.EVENT t
    ON t.event_start_dt BETWEEN h.hour_start_dt AND h.hour_end_dt
      AND t.event_cd = 14;