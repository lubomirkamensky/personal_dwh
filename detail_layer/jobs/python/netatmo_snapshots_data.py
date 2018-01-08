#!/usr/bin/python3

import os
from sys import exit
import datetime
import time
ts = time.time()

def xstr(s):
    return '' if s is None else str(s)

import json
myconfig = json.loads(open('config/local_mysql.json').read())

#Server Connection to MySQL:
import MySQLdb
con = MySQLdb.connect(**myconfig)
cur = con.cursor()

cur.execute("SELECT COALESCE(MAX(Observation_Id),0) \
             FROM pdwh_detail.observation")
row = cur.fetchone()
lastId = row[0]

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
                           s.Related_Observation_Id IS NULL"
# event type 13 outdoor --  15 sec range
# 11,12  person,movement --  5 sec range

tmp = open('./tmp_s.txt','w')
cur.execute(sqlGetNewCameraEvents)
rows = cur.fetchall()
for row in rows:
    if row[2] == 13:
        r = range(row[1],row[1] + 15)
    else:
        r = range(row[1],row[1] + 5)
    
    indir = './snapshots/' + row[4]
    for root, dirs, filenames in os.walk(indir):
        for f in filenames:
            if int(f.split('.')[0]) in r:
                lastId = lastId + 1

                # Observation_Id,Observation_Timestamp,Sensor_Id,Related_Observation_Id,Target_Table
                tmp.write(xstr(lastId)  + '\t' + f.split('.')[0]  + '\t' + xstr(row[3])  + '\t' + \
                          xstr(row[0]) + '\t' + 'camera_snapshot' + '\n')
                
                os.rename('./snapshots/' + row[4] + '/' + f, './snapshots/_tmp/' + xstr(lastId) + '.jpg')

tmp.close()
cur.execute("LOAD DATA LOCAL INFILE './tmp_s.txt' \
             IGNORE INTO TABLE pdwh_detail.observation;") 
con.commit()

if con:    
    con.close()

exit(0)   

