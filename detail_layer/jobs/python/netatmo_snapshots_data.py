#!/usr/bin/python3

import os
from sys import exit
import datetime
import time
ts = time.time()

def xstr(s):
    return '' if s is None else str(s)

import json
myconfig = json.loads(open('config/mysql.json').read())

#Server Connection to MySQL:
import MySQLdb
con = MySQLdb.connect(**myconfig)
cur = con.cursor()

cur.execute("SELECT COALESCE(MAX(Observation_Id),0) \
             FROM pdwh_detail.observation")
row = cur.fetchone()
lastId = row[0]

# to get events without related snapshot photos
sqlGetNewCameraEvents = "SELECT \
                           o.Observation_Id, \
                           o.Observation_timestamp, \
                           e.Event_Type_Id, \
                           o.Sensor_Id, \
                           p.Camera_Name \
                       FROM \
                           pdwh_detail.observation o \
                       INNER JOIN \
                           pdwh_detail.camera_event e \
                           ON o.Observation_Id = e.Event_Id \
                       INNER JOIN \
                           pdwh_detail.sensor c \
                           ON o.Sensor_Id = c.Sensor_Id \
                             AND c.Source_Name = 'api.netatmo.com' \
                       INNER JOIN pdwh_detail.camera p \
                           ON o.Sensor_Id = p.Camera_Id \
                       LEFT JOIN \
                           pdwh_detail.observation s \
                           ON o.Observation_Id = s.Related_Observation_Id \
                             AND s.Target_Table = 'camera_snapshot' \
                       WHERE \
                           p.Camera_Name <> 'Prizemi' \
                           AND o.Observation_timestamp > (UNIX_TIMESTAMP()-86400) \
                           AND o.Observation_Id NOT IN (\
                                                    SELECT \
                                                        Related_Observation_Id \
                                                    FROM \
                                                        pdwh_detail.observation \
                                                    WHERE \
                                                        Target_Table = 'camera_snapshot' \
                                                    GROUP BY 1 \
                                                   )" 

# event type 13 outdoor --  15 sec range
# 11,12  person,movement --  5 sec range

tmp = open('./tmp_s.txt','w', newline='\n')
cur.execute(sqlGetNewCameraEvents)
rows = cur.fetchall()
for row in rows:
    if row[2] == 13:
        # time range to get snapshot photos for
        r = range(row[1],row[1] + 40)
        # number of photos to collect for one event
        n = 3
    else:
        r = range(row[1],row[1] + 20)
        n = 1
    
    # Loops snapshot photos in camera folders 
    indir = './snapshots/' + row[4]
    for root, dirs, filenames in os.walk(indir):
        # list of all available snapshot photos in camera folder
        filenames = sorted([ int(f.split('.')[0]) for f in filenames if f != 'Thumbs.db' ])
        # intersection of available snapshot photos and requested time range
        filenames = list(set(filenames) & set(r))
        cnt = 1
        for f in filenames:
            # makes sure we callect just the required number of snapshot photos
            if cnt <= n:
                lastId = lastId + 1
                cnt = cnt + 1
                # Observation_Id,Observation_Timestamp,Sensor_Id,Related_Observation_Id,Target_Table
                tmp.write(xstr(lastId)  + '\t' + xstr(f)  + '\t' + xstr(row[3])  + '\t' + \
                          xstr(row[0]) + '\t' + 'camera_snapshot' + '\n')
                
                # gives the file the new name of db snapshot_id 
                # and moves the file to folder monitered by Google sync tool
                os.rename('./snapshots/' + row[4] + '/' + xstr(f) + '.jpg', './snapshots/Google_Gate/camera_snapshot_' \
                          + xstr(lastId) + '.jpg')

tmp.close()
cur.execute("LOAD DATA LOCAL INFILE './tmp_s.txt' \
             IGNORE INTO TABLE pdwh_detail.observation;") 
con.commit()

if con:    
    con.close()

# removes snapshot photos older than two hours from camera folders
for d in ["Prizemi","VCHOD","Zahrada","Garaz","StudnaSZ","StudnaJV"]:
    indir = './snapshots/' + d
    for root, dirs, filenames in os.walk(indir):
        filenames = [ int(f.split('.')[0]) for f in filenames \
                      if f != 'Thumbs.db' and int(f.split('.')[0]) < round(time.time()) - 7200 ]
        for f in filenames:
            os.remove(indir + '/' + xstr(f)+ '.jpg') 
        


exit(0)   
