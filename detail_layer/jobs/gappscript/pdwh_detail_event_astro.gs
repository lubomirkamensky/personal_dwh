// Inserts Astro Events (Sun, Moon rise and sets, Moon phases) into detail event table

function astroEvents() {

 // Cloud SQL
 var address = 'XX.XX.XX.XX';
 var user = 'user';
 var userPwd = 'password';
 var db = 'pdwh_detail';
 var dbUrl = 'jdbc:mysql://' + address + '/' + db;
 var conn = Jdbc.getConnection(dbUrl, user, userPwd);
 var eventTypeKeys = {"BC":1, "R":2, "U":3,"S":4,"EC":5, "L":6, "New Moon":7, "First Quarter":8, "Full Moon":9, "Last Quarter":10};
 var monthMap = {"Jan":"01", "Feb":"02", "Mar":"03", "Apr":"04", "May":"05", "Jun":"06", "Jul":"07", "Aug":"08", "Sep":"08", "Oct":"10", "Nov":"11", "Dec":"12"};
  
 // Deletes curent scope of records in even table to avoid duplicates 
 var stmt = conn.prepareStatement('CALL pdwh_detail.delete_astro_devents_in_scope()');
 stmt.execute();
 stmt.close();
 
 // Takes max 300 days from the actual load range 
 var stmt = conn.createStatement(); 
 stmt.setMaxRows(300);
 var daysRange = stmt.executeQuery('SELECT Day,Day_Dt FROM pdwh_detail.v_event_astro_range_day ORDER BY Day_Id'); 

 // Take max 10 years from the actual load range 
 var stmt = conn.createStatement();
 stmt.setMaxRows(10);
 var yearsRange = stmt.executeQuery('SELECT Year_Id FROM pdwh_detail.v_event_astro_range_year ORDER BY Year_Id'); 

 // Constructs template for Insert statement into event table
 var stmt = conn.prepareStatement('INSERT INTO pdwh_detail.event (Subject_Id, Event_Type_Id, Event_Start_Dt, Event_End_Dt) values (?, ?, ?, ?)');
  
 // Loops through day range and request data from remote api, use the data to complete the Insert statement using the template
 while (daysRange.next()) {
   Logger.log(daysRange.getString(1));
   var response = UrlFetchApp.fetch("http://api.usno.navy.mil/rstt/oneday?date=" + daysRange.getString(1) + "&coords=48.749015N,16.983294E&tz=1");
   var parsed = JSON.parse(response.getContentText());

   // Gets Sun Events
   stmt.setString(1, 1);
   parsed.sundata.forEach(function(entry) {
     stmt.setString(2, eventTypeKeys[entry.phen]);
     stmt.setString(3, daysRange.getString(2) + " " + entry.time);
     stmt.setString(4, daysRange.getString(2) + " " + entry.time);
     //add completed Insert statement into the batch
     stmt.addBatch();
   });
   
   // Gets Moon Events
   stmt.setString(1, 2);
   parsed.moondata.forEach(function(entry) {
     stmt.setString(2, eventTypeKeys[entry.phen]);
     stmt.setString(3, daysRange.getString(2) + " " + entry.time);
     stmt.setString(4, daysRange.getString(2) + " " + entry.time);
     stmt.addBatch();
   });
 } 

 // Loops through year range and request data from remote api, use the data to complete the Insert statement using the template
 while (yearsRange.next()) {
   Logger.log(yearsRange.getString(1));
   var response = UrlFetchApp.fetch("http://api.usno.navy.mil/moon/phase?year=" + yearsRange.getString(1));
   var parsed = JSON.parse(response.getContentText());

   // Get Moon Phases
   stmt.setString(1, 2);
   parsed.phasedata.forEach(function(entry) {
     var dateArrey = entry.date.split(" ")
     stmt.setString(2, eventTypeKeys[entry.phase]);
     stmt.setString(3, dateArrey[0] + "-" + monthMap[dateArrey[1]] + "-" + dateArrey[2] + " " + entry.time);
     stmt.setString(4, dateArrey[0] + "-" + monthMap[dateArrey[1]] + "-" + dateArrey[2] + " " + entry.time);
     stmt.addBatch();
   });
 } 

 // Executes all added insert statements in one batch 
 var batch = stmt.executeBatch();
 conn.close(); 
}
