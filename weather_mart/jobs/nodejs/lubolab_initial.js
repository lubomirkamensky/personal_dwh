var lubolab = {}; 
lubolab['Measures'] = {}; 
lubolab['Measures']['Weather'] = {}; 
var measures = ['Temperature','Rain','Pressure','Wind Speed','Humidity','Dewpoint'];
var grain = ['Yearly','Monthly','Daily','Hourly']
for (var i = 0; i < measures.length; i++) {
    lubolab['Measures']['Weather'][measures[i]] = {};
    for (var e = 0; e < grain.length; e++) {
        lubolab['Measures']['Weather'][measures[i]][grain[e]] = {};    
    } 
}

var mysql = require('mysql');
var connection = mysql.createConnection({
  host     : 'cloudserver',
  user     : 'pdwh',
  password : 'password',
  database : 'pdwh_mart_weather'
});
connection.connect();

var sql = 'SELECT "Yearly" AS Grain, Year_id AS Period, Outdoor_Temp_MIN, Outdoor_Temp_MAX, Outdoor_Temp_AVG, Actual_Rain, Relative_Pressure_MIN, Relative_Pressure_MAX, Relative_Pressure_AVG, Outdoor_Hum_MIN, Outdoor_Hum_MAX, Outdoor_Hum_AVG, Dewpoint_MIN, Dewpoint_MAX, Dewpoint_AVG, Wind_Speed_MIN, Wind_Speed_MAX, Wind_Speed_AVG FROM vs_all_measures_yearly4year'
sql = sql + ' UNION ALL SELECT "Monthly" AS Grain, Month_id AS Period, Outdoor_Temp_MIN, Outdoor_Temp_MAX, Outdoor_Temp_AVG, Actual_Rain, Relative_Pressure_MIN, Relative_Pressure_MAX, Relative_Pressure_AVG, Outdoor_Hum_MIN, Outdoor_Hum_MAX, Outdoor_Hum_AVG, Dewpoint_MIN, Dewpoint_MAX, Dewpoint_AVG, Wind_Speed_MIN, Wind_Speed_MAX, Wind_Speed_AVG FROM vs_all_measures_monthly4month'
sql = sql + ' UNION ALL SELECT "Daily" AS Grain, Day_id AS Period, Outdoor_Temp_MIN, Outdoor_Temp_MAX, Outdoor_Temp_AVG, Actual_Rain, Relative_Pressure_MIN, Relative_Pressure_MAX, Relative_Pressure_AVG, Outdoor_Hum_MIN, Outdoor_Hum_MAX, Outdoor_Hum_AVG, Dewpoint_MIN, Dewpoint_MAX, Dewpoint_AVG, Wind_Speed_MIN, Wind_Speed_MAX, Wind_Speed_AVG FROM vs_all_measures_daily4day'
sql = sql + ' UNION ALL SELECT "Hourly" AS Grain, Hour_id AS Period, Outdoor_Temp_MIN, Outdoor_Temp_MAX, Outdoor_Temp_AVG, Actual_Rain, Relative_Pressure_MIN, Relative_Pressure_MAX, Relative_Pressure_AVG, Outdoor_Hum_MIN, Outdoor_Hum_MAX, Outdoor_Hum_AVG, Dewpoint_MIN, Dewpoint_MAX, Dewpoint_AVG, Wind_Speed_MIN, Wind_Speed_MAX, Wind_Speed_AVG FROM vs_all_measures_hourly4day'

connection.query(sql, function(err, rows, fields) {
  if (err) throw err;

  for (var i = 0;i < rows.length; i++) {
    lubolab['Measures']['Weather']['Temperature'][rows[i].Grain][rows[i].Period] = [formatTime(rows[i].Period), rows[i].Outdoor_Temp_MIN,rows[i].Outdoor_Temp_MAX,rows[i].Outdoor_Temp_AVG];
    lubolab['Measures']['Weather']['Rain'][rows[i].Grain][rows[i].Period] = [formatTime(rows[i].Period), rows[i].Actual_Rain];
    lubolab['Measures']['Weather']['Pressure'][rows[i].Grain][rows[i].Period] = [formatTime(rows[i].Period), rows[i].Relative_Pressure_MIN,rows[i].Relative_Pressure_MAX,rows[i].Relative_Pressure_AVG];
    lubolab['Measures']['Weather']['Humidity'][rows[i].Grain][rows[i].Period] = [formatTime(rows[i].Period), rows[i].Outdoor_Hum_MIN,rows[i].Outdoor_Hum_MAX,rows[i].Outdoor_Hum_AVG];
    lubolab['Measures']['Weather']['Dewpoint'][rows[i].Grain][rows[i].Period] = [formatTime(rows[i].Period), rows[i].Dewpoint_MIN,rows[i].Dewpoint_MAX,rows[i].Dewpoint_AVG];
    lubolab['Measures']['Weather']['Wind Speed'][rows[i].Grain][rows[i].Period] = [formatTime(rows[i].Period), rows[i].Wind_Speed_MIN,rows[i].Wind_Speed_MAX,rows[i].Wind_Speed_AVG];
    console.log(formatTime(rows[i].Period))
  }
  var fs = require('fs');
  fs.writeFile("C:/Program Files/nodejs/node_modules/lubolab/lubolab.json", JSON.stringify(lubolab));
  console.log('updated lubolab.json');

  connection.query('CALL sp_load_firebase_periods()',function(err,rows){
    if (err) throw err;

    console.log('Loaded firebase periods');
    connection.end();
  });
  
  function formatTime(period) {
    var xperiod =  period.substring(0, 4) //YYYY
    if (period.length  > 4) {
      xperiod = xperiod + "-" + period.substring(4, 6)   //YYYY-MM
    }
    if (period.length  > 6) {
      xperiod = xperiod + "-" + period.substring(6, 8)   //YYYY-MM-DD
    }
    if (period.length  > 8) {
      xperiod = xperiod + " " + period.substring(8, 10)   //YYYY-MM-DD:HH
    }
    return xperiod;              
  }
  
});






