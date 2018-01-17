function sortphotos() {
  var googleFolder = DriveApp.getFoldersByName("Fotky Google").next();
  var root = googleFolder.getFoldersByName("Archiv").next();
  var other = root.getFoldersByName("Other").next();
  var files = root.getFiles();
  var i = 0;

  // Cloud SQL
  var address = 'XX.XX.XX.XX';
  var user = 'XXXXX';
  var userPwd = 'XXXXXXX';
  var db = 'pdwh_detail';
  var dbUrl = 'jdbc:mysql://' + address + '/' + db;
  var conn = Jdbc.getConnection(dbUrl, user, userPwd);

  
  while (files.hasNext() && i < 33) {
    var file = files.next();
    var fileId = file.getId()
    var imageMediaMetadata = Drive.Files.get(fileId).imageMediaMetadata
    if (typeof(Drive.Files.get(fileId).imageMediaMetadata.date) != "undefined") {
      var camera = Drive.Files.get(fileId).imageMediaMetadata.cameraModel;
      var date = Drive.Files.get(fileId).imageMediaMetadata.date
    }
    else {
      var date = new Date(file.getDateCreated()).toISOString();
    }
    
    if (typeof(date) == "undefined") {
      var date = new Date().toISOString();
    }
    
    var folderYear = date.substring(0,4);
    var folderMonth = date.substring(0,7).replace(":","-");
    var folderDate = date.substring(0,10).replace(/:/g,"-");

    if(root.getFoldersByName(folderYear).hasNext()) {
      var parent = root.getFoldersByName(folderYear).next();
    } 
    else {
      var parent = root.createFolder(folderYear);
    }
    if(parent.getFoldersByName(folderMonth).hasNext()) {
      var folder0 = parent.getFoldersByName(folderMonth).next();
    } 
    else {
      var folder0 = parent.createFolder(folderMonth);
    }
    if(folder0.getFoldersByName(folderDate).hasNext()) {
      var folder = folder0.getFoldersByName(folderDate).next();
    } 
    else {
      var folder = folder0.createFolder(folderDate);
    }

    if (file.getName().substring(0,15) == "camera_snapshot") {

      var event_id = file.getName().split("_")[2].replace(".jpg","");
      
      var sqlstring = 'INSERT INTO pdwh_detail.camera_snapshot(Snapshot_Id,File_Name,File_ID) SELECT Observation_Id,?,? FROM pdwh_detail.observation WHERE Target_Table = ? AND Observation_Id = ?';
      Logger.log(sqlstring);
      var stmt = conn.prepareStatement(sqlstring);
      stmt.setString(1, file.getName());
      stmt.setString(2, fileId);
      stmt.setString(3, 'camera_snapshot');
      stmt.setString(4, event_id);
      stmt.execute();
      stmt.close();

    }
    else if (typeof(camera) != "undefined") {
      var fileName = "CAMERA_"+date+"_"+camera+".JPG";
      file.setName(fileName);
    }
    else {   
      var fileName = "OTHER_"+file.getDateCreated()+"_"+file.getId()+".JPG";
      file.setName(fileName);
    }

    if(folder.getFilesByName(fileName).hasNext()) {
      root.removeFile(file);
      Logger.log("photo already exists"); 
    } 
    else {
      folder.addFile(file);
      root.removeFile(file);
      Logger.log("added new photo");
    }

    i = i + 1;
    Logger.log(i);  
  }
  conn.close();

}
