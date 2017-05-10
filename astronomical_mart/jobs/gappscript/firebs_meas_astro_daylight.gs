// Builds Astro acess layer (hourly, daily, monthly, yearly) in Firebase, using  hourly Astro datamart view

function firebsMeasAstroDaylight() {
  
 // Cloud SQL Connection Setup
 var address = 'XX.XX.XX.XX';
 var user = 'user';
 var userPwd = 'password';
 var db = 'pdwh_detail';
 var dbUrl = 'jdbc:mysql://' + address + '/' + db;
 var conn = Jdbc.getConnection(dbUrl, user, userPwd);
  
 // Firebase Connection Setup
 var firebaseUrl = "https://lubolab-957a1.firebaseio.com/";
 var secret = "VzmedbuKrFygnGJwWJG7KwyYmiD4huP61wEw0o7d";
 var base = FirebaseApp.getDatabaseByUrl(firebaseUrl, secret); 
  
 // Takes hourly daylight from Astro datamart view, limited by actual load range and forced to max 600 records
 var hStmt = conn.createStatement(); 
 hStmt.setMaxRows(600);
 var hoursRange = hStmt.executeQuery('select Hour_Id, Hour_Val, Daylight_Length from pdwh_mart_astronomical.v_firebase_hourly order by 1'); 
 var hourID = 0; 

 // Loop through resultset and insert/update each record in Firebase
 while (hoursRange.next()) {
   hourID = hoursRange.getString(1);
   base.setData("Measures/Astronomical/Daylight/Hourly/" + hoursRange.getString(1), [hoursRange.getString(2), hoursRange.getInt(3)]);
   
   // For last hour in the Year also yearly, monthly and daily accumulations are processed
   if (hoursRange.getString(1).substring(4,10) == '010123') {
     
     // Takes yearly daylight from Astro datamart view
     var yStmt = conn.createStatement();
     yStmt.setMaxRows(1);
     var yearsRange = yStmt.executeQuery('select SUM(Daylight_Length) from pdwh_mart_astronomical.v_daylight_length_hourly where Substr(Hour_Id,1,4) = ' + hoursRange.getString(1).substring(0,4));
     // Loop through resultset and insert/update each record in Firebase
     while (yearsRange.next()) {
       base.setData("Measures/Astronomical/Daylight/Yearly/" + hoursRange.getString(1).substring(0,4), [hoursRange.getString(1).substring(0,4), yearsRange.getInt(1)]);
     }
     yStmt.close()
     
     // Takes monthly daylight from Astro datamart view
     var mStmt = conn.createStatement();
     mStmt.setMaxRows(12);
     var monthsRange = mStmt.executeQuery("select Substr(Hour_Id,1,6) as Month_Id, CONCAT(Substr(Hour_Id,1,4),'-',Substr(Hour_Id,5,2)) AS Month_Val, SUM(Daylight_Length) from pdwh_mart_astronomical.v_daylight_length_hourly where Substr(Hour_Id,1,4) = "+ hoursRange.getString(1).substring(0,4) +" group by 1,2");
     // Loop through resultset and insert/update each record in Firebase
     while (monthsRange.next()) {
       base.setData("Measures/Astronomical/Daylight/Monthly/" + monthsRange.getString(1), [monthsRange.getString(2), monthsRange.getInt(3)]);
     }
     mStmt.close()
     
     // Takes daily daylight from Astro datamart view
     var dStmt = conn.createStatement();
     dStmt.setMaxRows(366);
     var daysRange = dStmt.executeQuery("select Substr(Hour_Id,1,8) as Day_Id, CONCAT(Substr(Hour_Id,1,4),'-',Substr(Hour_Id,5,2),'-',Substr(Hour_Id,7,2)) AS Day_Val, SUM(Daylight_Length) from pdwh_mart_astronomical.v_daylight_length_hourly where Substr(Hour_Id,1,4) = "+ hoursRange.getString(1).substring(0,4) +" group by 1,2");
     // Loop through resultset and insert/update each record in Firebase
     while (daysRange.next()) {
       base.setData("Measures/Astronomical/Daylight/Daily/" + daysRange.getString(1), [daysRange.getString(2), daysRange.getInt(3)]);
     }
     dStmt.close()
   }  
 } 
  if (hourID > 0) {
     // Inserts into load driving table  t_loaded_periods
     var stmt = conn.prepareStatement('insert into pdwh_mart_astronomical.t_loaded_periods select max(Hour_Id) from (select Hour_Id from pdwh_mart_astronomical.v_firebase_hourly limit 600) A');
     stmt.execute();
     conn.close(); 
     Logger.log(hourID); 
    }
}
