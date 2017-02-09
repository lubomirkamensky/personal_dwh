##############################################################################
## Weather_rupload.ps1
##
## Weather_measuring Remote uploader
##############################################################################
## Open connection to system database
[system.reflection.assembly]::LoadWithPartialName("MySql.Data")
$cn = New-Object -TypeName MySql.Data.MySqlClient.MySqlConnection
$cn.ConnectionString = "SERVER=cloudserver;DATABASE=pdwh_detail;UID=pdwh;PWD=password"
$cn.Open()

$cn1 = New-Object -TypeName MySql.Data.MySqlClient.MySqlConnection
$cn1.ConnectionString = "SERVER=cloudserver;DATABASE=pdwh_detail;UID=pdwh;PWD=password"
$cn1.Open()

$cn0 = New-Object -TypeName MySql.Data.MySqlClient.MySqlConnection
$cn0.ConnectionString = "SERVER=cloudserver;DATABASE=pdwh_mart_weather;UID=pdwh;PWD=password"
$cn0.Open()

$cn2 = New-Object -TypeName MySql.Data.MySqlClient.MySqlConnection
$cn2.ConnectionString = "SERVER=localhost;DATABASE=personal_dwh;UID=root;PWD=password"
$cn2.Open()

$cn3 = New-Object -TypeName MySql.Data.MySqlClient.MySqlConnection
$cn3.ConnectionString = "SERVER=localhost;DATABASE=personal_dwh;UID=root;PWD=password"
$cn3.Open()

$cm = New-Object -TypeName MySql.Data.MySqlClient.MySqlCommand
$sql = "SELECT MAX(Insert_Dt) FROM pdwh_detail.weather_measuring"
$cm.Connection = $cn
$cm.CommandText = $sql
$dr = $cm.ExecuteReader()

while ($dr.Read())
{
    $last_insert = $dr.GetString(0)
    $last_insert =  Get-Date $last_insert -format "yyyy-MM-dd HH:mm"  
}

$cm2 = New-Object -TypeName MySql.Data.MySqlClient.MySqlCommand
$sql2 = "SELECT MAX(Insert_Dt) FROM personal_dwh.weather_measuring"
$cm2.Connection = $cn2
$cm2.CommandText = $sql2
$dr2 = $cm2.ExecuteReader()
while ($dr2.Read())
{
    $max_insert = $dr2.GetString(0)  
    $max_insert =  Get-Date $max_insert -format "yyyy-MM-dd HH:mm"
}

if (Test-Path C:\personaldwh\WEATHER_MEASURING.txt)
{
    Remove-Item C:\personaldwh\WEATHER_MEASURING.txt -force
}

$cm3 = New-Object -TypeName MySql.Data.MySqlClient.MySqlCommand
$sql3 = "SELECT * INTO OUTFILE 'C:/personaldwh/WEATHER_MEASURING.txt' FROM personal_dwh.weather_measuring WHERE Insert_Dt > '$last_insert' AND Insert_Dt < '$max_insert';"
$cm3.Connection = $cn3
$cm3.CommandText = $sql3
$cm3.ExecuteNonQuery()

$cm1 = New-Object -TypeName MySql.Data.MySqlClient.MySqlCommand
$sql1 = "LOAD DATA LOCAL INFILE  'C:/personaldwh/WEATHER_MEASURING.txt' IGNORE INTO TABLE  pdwh_detail.weather_measuring;"
$cm1.Connection = $cn1
$cm1.CommandText = $sql1
$cm1.ExecuteNonQuery()

$cm0 = New-Object -TypeName MySql.Data.MySqlClient.MySqlCommand
$sql0 = "CALL sp_load_actual_rain();"
$cm0.Connection = $cn0
$cm0.CommandText = $sql0
$cm0.ExecuteNonQuery()


$sql3 = "DELETE FROM personal_dwh.weather_measuring WHERE Insert_Dt < '$last_insert';"
$cm3.CommandText = $sql3
$cm3.ExecuteNonQuery()
