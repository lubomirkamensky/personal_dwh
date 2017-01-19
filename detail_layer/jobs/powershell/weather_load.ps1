##############################################################################
## Weather_load.ps1
##
## Weather_measuring Loader
##############################################################################
## Open connection to system database
[system.reflection.assembly]::LoadWithPartialName("MySql.Data")
$cn = New-Object -TypeName MySql.Data.MySqlClient.MySqlConnection
$cn.ConnectionString = "SERVER=localhost;DATABASE=personal_dwh;UID=root;PWD=password"
$cn.Open()

function Get-IniContent ($filePath)
{
    $ini = @{}
    switch -regex -file $FilePath
    {
        "^\[(.+)\]" # Section
        {
            $section = $matches[1]
            $ini[$section] = @{}
            $CommentCount = 0
        }
        "^(;.*)$" # Comment
        {
            $value = $matches[1]
            $CommentCount = $CommentCount + 1
            $name = "Comment" + $CommentCount
            $ini[$section][$name] = $value
        } 
        "(.+?)\s*=(.*)" # Key
        {
            $name,$value = $matches[1..2]
            $ini[$section][$name] = $value
        }
    }
    return $ini
}

$iniContent = Get-IniContent “c:\ProgramData\currdat.lst”
$xsec = $iniContent[“time”][“last_actualisation”]
$xsec = $xsec.Replace('"','')
$xdate = (Get-Date "1/1/1900 1:00 AM").AddSeconds($xsec)
$Datetime = Get-Date $xdate -format "yyyy-MM-dd HH:mm"
$Total_Rain = $iniContent[“rain_total”][“mm”] 
$Relative_Pressure = $iniContent[“pressure_relative”][“hpa”]
$Indoor_Temp = $iniContent[“indoor_temperature”][“deg_C”]
$Outdoor_Temp = $iniContent[“outdoor_temperature”][“deg_C”]
$Indoor_Hum = $iniContent[“indoor_humidity”][“percent”] 
$Outdoor_Hum = $iniContent[“outdoor_humidity”][“percent”]
$Dewpoint = $iniContent[“dewpoint”][“deg_C”]
$Wind_Speed = $iniContent[“wind_speed”][“mps”]
$Wind_Chill = $iniContent[“windchill”][“deg_C”]
$Wind_Direction = $iniContent[“wind_direction”][“name”]

$cm = New-Object -TypeName MySql.Data.MySqlClient.MySqlCommand
$sql = "INSERT INTO personal_dwh.weather_measuring_current(Datetime, Total_Rain, Relative_Pressure, Indoor_Temp, Outdoor_Temp, Indoor_Hum, Outdoor_Hum, Dewpoint, Wind_Speed, Wind_Chill, Wind_Direction) VALUES('$Datetime', $Total_Rain, $Relative_Pressure, $Indoor_Temp, $Outdoor_Temp, $Indoor_Hum, $Outdoor_Hum, $Dewpoint, $Wind_Speed, $Wind_Chill, '$Wind_Direction')"
$cm.Connection = $cn
$cm.CommandText = $sql
$cm.ExecuteNonQuery()

$sql = "INSERT INTO personal_dwh.weather_measuring(Datetime,Total_Rain,Relative_Pressure,Indoor_Temp,Outdoor_Temp,Indoor_Hum,Outdoor_Hum,Dewpoint,Wind_Speed,Wind_Chill,Wind_Direction) SELECT * FROM personal_dwh.weather_measuring_curr_load"
$cm.CommandText = $sql
$cm.ExecuteNonQuery()

$sql = "DELETE FROM personal_dwh.weather_measuring_current"
$cm.CommandText = $sql
$cm.ExecuteNonQuery()
