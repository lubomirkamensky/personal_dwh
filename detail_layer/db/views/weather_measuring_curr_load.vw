CREATE VIEW pdwh_detail.weather_measuring_curr_load AS
SELECT 
    WMC.*
FROM
    pdwh_detail.weather_measuring_current WMC
LEFT JOIN
    pdwh_detail.weather_measuring WM 
    ON WMC.Datetime = WM.Datetime
WHERE
    WM.Datetime IS NULL;