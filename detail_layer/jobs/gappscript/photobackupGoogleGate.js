function photobackupGoogleGate() {
  var source_folder = DriveApp.getFolderById("1QJ8qhtUDPqPifMjkcUhd6tz27qruOe6P"); // folder Computers/Mylaptop/Google_Gate
  var dest_folder = DriveApp.getFolderById("0B8vnNdF_s6mxWGo1NF9IYnM1ZDQ");  // folder My drive/Photos Google/Archive
  
  var files = source_folder.getFiles();
  var i = 0;
  
  while (files.hasNext() && i < 33) {
 
    var file = files.next();
    dest_folder.addFile(file);
    source_folder.removeFile(file);
    Logger.log(i);
    i = i + 1;
 
  }


}