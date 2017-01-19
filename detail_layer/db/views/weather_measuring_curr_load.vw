CREATE VIEW weather_measuring_curr_load AS
SELECT 
    WMC.*
FROM
    weather_measuring_current WMC
LEFT JOIN
    weather_measuring WM 
    ON WMC.Datetime = WM.Datetime
WHERE
    WM.Datetime IS NULL;