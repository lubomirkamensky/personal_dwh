#!/usr/bin/python3

import traceback
import sys
import os
from sys import exit
from urllib import request
import lnetatmo
import datetime
import time
ts = time.time()

log = open("log_events.txt", "w")

def xstr(s):
    return '' if s is None else str(s)

# Db connection setup for both local and cloud mysql
import json
config = json.loads(open('config/netatmo.json').read())
myconfig = json.loads(open('config/mysql.json').read())

#Server Connection to MySQL:
import MySQLdb
con = MySQLdb.connect(**myconfig)
cur = con.cursor()

# Netatmo Authenticate (see authentication in documentation)
authorization = lnetatmo.ClientAuth(**config)

# Gather Home information (available cameras and other infos)
homeData = lnetatmo.HomeData(authorization)

# define one record in batch file loading the super table.
# this method is overwritten for each particular table
def getRowString(value):
    stringOneRow = value['id'] + '\t' + value['type'] + '\tapi.netatmo.com\tcamera' + '\n'
    return stringOneRow

# common pattern for loading super type table
def loadSuperTable(targetTable,sqlGetloadedItems,allItems,sqlGetlastId):
    try:
        loadedItems = []
        # batch file, fix for windows line end works for python 3.x
        tmp = open('./tmp.txt','w', newline='\n')
        lastId = 0
        
        # extracts source keys for data loaded earlier
        cur.execute(sqlGetloadedItems)
        rows = cur.fetchall()
        for row in rows:
            loadedItems.append(row[0]) 
       
        # excludes data loaded earlier
        newItems = { key:value for key, value in allItems.items() if key not in loadedItems } 

        # gets MAX surrogate key from loaded data
        cur.execute(sqlGetlastId)
        row = cur.fetchone()
        lastId = row[0]

        # generates the batch file for the new load
        for value in newItems.values():
            lastId = lastId + 1
            tmp.write('' + xstr(lastId) + '\t' + getRowString(value)) 
    
        tmp.close()
        
        cur.execute("LOAD DATA LOCAL INFILE './tmp.txt' IGNORE INTO TABLE pdwh_detail." + targetTable + ";")  
        con.commit()

    except Exception:
        traceback.print_exc(file=log)
        log.close()       

# common pattern for loading sub type table, similar as above but simplified  
def loadSubTable(targetTable,allItems,nameKey,sqlGetSubTableItems):
    names = { value['id']: value[nameKey] for key, value in allItems.items()  } 
    tmp = open('./tmp.txt','w', newline='\n')

    cur.execute(sqlGetSubTableItems)
    rows = cur.fetchall()
    for row in rows:
        tmp.write('' + xstr(row[1]) + '\t' + names[row[0]] + '\n')
    
    tmp.close()
    
    cur.execute("LOAD DATA LOCAL INFILE './tmp.txt' IGNORE INTO TABLE pdwh_detail." + targetTable + ";")  
    con.commit()

# Sensor > Camera
sqlGetloadedItems = "SELECT Sensor_Source_Cd \
                     FROM pdwh_detail.sensor \
                     WHERE Target_Table = 'camera';"
allItems = homeData.cameras["Nas dum"]
sqlGetlastId = "SELECT COALESCE(MAX(Sensor_Id),0) FROM pdwh_detail.sensor;"
loadSuperTable("sensor",sqlGetloadedItems,allItems,sqlGetlastId)

sqlGetSubTableItems = "SELECT Sensor_Source_Cd,Sensor_Id \
                       FROM pdwh_detail.sensor s \
                       LEFT JOIN pdwh_detail.camera c ON s.Sensor_Id = c.Camera_Id \
                       WHERE s.Target_Table = 'camera' and c.Camera_Id IS NULL;"
loadSubTable('camera',allItems,'name',sqlGetSubTableItems)

# Entity > Person
sqlGetloadedItems = "SELECT Entity_Source_Cd \
                     FROM pdwh_detail.entity \
                     WHERE Target_Table = 'person';"
allItems = { key:value for key, value in homeData.persons.items() if 'pseudo' in value.keys() }
sqlGetlastId = "SELECT COALESCE(MAX(Entity_Id),0) \
                FROM pdwh_detail.entity;"

# overwritting the method
def getRowString(value):
    stringOneRow = value['id'] + '\tapi.netatmo.com\tperson' + '\n'
    return stringOneRow
loadSuperTable("entity",sqlGetloadedItems,allItems,sqlGetlastId)

sqlGetSubTableItems = "SELECT Entity_Source_Cd,Entity_Id \
                       FROM pdwh_detail.entity s \
                       LEFT JOIN pdwh_detail.person c ON s.Entity_Id = c.Person_Id  \
                       WHERE s.Target_Table = 'person' and c.Person_Id IS NULL;"
loadSubTable('person',allItems,'pseudo',sqlGetSubTableItems)

# Observation > Event > Label

# make dictionaries representing all needed master data tables
event_type = {'person':11,'movement':12,'outdoor':13}

label = {'human':1,'vehicle':2,'animal':3}

person = {}
cur.execute("SELECT Entity_Id,Entity_Source_Cd \
             FROM pdwh_detail.entity \
             WHERE Target_Table = 'person' AND Source_Name = 'api.netatmo.com';")
rows = cur.fetchall()
for row in rows:
    person[row[1]] = row[0]

camera = {}
cur.execute("SELECT s.Sensor_Id,s.Sensor_Source_Cd,p.Camera_Name \
             FROM pdwh_detail.sensor s \
             INNER JOIN pdwh_detail.camera p ON s.Sensor_Id = p.Camera_Id \
             WHERE s.Target_Table = 'camera' AND s.Source_Name = 'api.netatmo.com';")
rows = cur.fetchall()
for row in rows:
    # Camera Source Cd: (Camera Surrogate Key, MAX timestamp, Camera Name)
    camera[row[1]] = [row[0],0,row[2]]

# gets MAX timestamp for each camera from already loaded data
cur.execute("SELECT s.Sensor_Source_Cd,COALESCE(MAX(o.Observation_Timestamp),0) \
             FROM  pdwh_detail.observation o \
             INNER JOIN pdwh_detail.sensor s ON o.Sensor_Id = s.Sensor_Id \
             WHERE s.Target_Table = 'camera' AND s.Source_Name = 'api.netatmo.com' \
             GROUP BY 1")
rows = cur.fetchall()

# stores the values in camera dictionary
for row in rows:
    camera[row[0]][1] = row[1]

# gets MAX surrogate keys from loaded data
cur.execute("SELECT COALESCE(MAX(Observation_Id),0) \
             FROM pdwh_detail.observation")
row = cur.fetchone()
lastId = row[0]

cur.execute("SELECT COALESCE(MAX(Observation_label_related_Id),0) \
             FROM pdwh_detail.observation_label_related")
row = cur.fetchone()
lastId2 = row[0]

tmp = open('./tmp.txt','w', newline='\n')
tmp2 = open('./tmp2.txt','w', newline='\n')
tmp3 = open('./tmp3.txt','w', newline='\n')
tmp4 = open('./tmp4.txt','w', newline='\n')

# stores snapshot photos from netatmo api urls
def saveFromUrl(cameraKey,cameraDict,snapshoDict):
    if 'id' in snapshoDict[1].keys():
        url = "https://api.netatmo.com/api/getcamerapicture?image_id=" \
        + snapshoDict[1]['id'] + "&key=" + snapshoDict[1]['key']
    elif 'filename' in snapshoDict[1].keys():
        url = homeData.cameraUrls(cid=cameraKey)[0] + '/' + snapshoDict[1]['filename']
    else:
        url = ""

    snapshotPath = "./snapshots/" + xstr(cameraDict[cameraKey][2]) + "/" + xstr(snapshoDict[0]) + ".jpg"
    f = open(snapshotPath, 'wb')
    f.write(request.urlopen(url).read())
    f.close()

# Loops all new events in netatmo api and pick useful data

try:

    for i in homeData.events.keys():
        xEvents = homeData.events[i]

        p1 = [ [  value['time'],
                  value['type'],
                  value['person_id'],
                  [value['time'],value['snapshot']] ]
                if 'snapshot' in value.keys() and 'person_id' in value.keys() 
                else [
                      value['time'],
                      value['type'],
                      [value['time'],value['snapshot']]]
                if 'snapshot' in value.keys()
                else [value['time'],
                      value['type'],
                      value['person_id']] 
                if 'person_id' in value.keys() 
                else [value['time'],
                      value['type'],
                      # using set to get distinct event types from the whole event list
                      set([i['type'] for i in value['event_list']]),
                      [[i['time'],i['snapshot']] if 'snapshot' in i.keys() else [] for i in value['event_list'] ]] 
                if 'event_list' in value.keys() 
                else [value['time'],
                      value['type']] 
                for key, value in xEvents.items() if key > camera[i][1]  ]

# Loops selected data fragments to generate SQL to be loaded and snapshot photos to be stored

        for x in p1:
            lastId = lastId + 1
            # prepare load for observation table
            tmp.write(xstr(lastId)  + '\t' + xstr(x[0]) + '\t' + xstr(camera[i][0]) + '\t' +  \
                      'camera_event' + '\n')

            if x[1] == 'person': 
                # prepare load for event table
                tmp4.write(xstr(lastId)  + '\t' + \
                           datetime.datetime.fromtimestamp(x[0]).strftime('%Y-%m-%d %H:%M:%S') + '\t' + \
                           xstr(person[x[2]]) + '\t' + \
                           xstr(event_type[x[1]]) + '\n')
                
                # stores snapshot photos from netatmo api
                if x[1] == 'person' and len(x) == 4:
                    for y in x[3]:
                        saveFromUrl(i,camera,y)
            
            # prepare load for event table
            else:
                tmp2.write(xstr(lastId)  + '\t' + \
                           datetime.datetime.fromtimestamp(x[0]).strftime('%Y-%m-%d %H:%M:%S') + '\t' + \
                           xstr(event_type[x[1]]) + '\n')
                
                # stores snapshot photos from netatmo api
                if x[1] == 'movement' and len(x) == 3:
                    for y in x[2]:
                        saveFromUrl(i,camera,y)

            # load event labels
            if x[1] == 'outdoor': 
                for y in x[2]:
                    lastId2 = lastId2 + 1
                    tmp3.write(xstr(lastId2)  + '\t' + xstr(lastId)  + '\t' + xstr(label[y]) + '\n')

                # stores snapshot photos from netatmo api
                if x[1] == 'outdoor' and len(x) == 4:
                    for y in x[3]:
                        saveFromUrl(i,camera,y)
 
except Exception:
    traceback.print_exc(file=log)
    log.close()       
   
tmp.close()
tmp2.close()
tmp3.close()
tmp4.close()
        
cur.execute("LOAD DATA LOCAL INFILE './tmp.txt' \
             IGNORE INTO TABLE pdwh_detail.observation(Observation_Id,\
                                                       Observation_Timestamp,\
                                                       Sensor_Id,\
                                                       Target_Table);")  

cur.execute("LOAD DATA LOCAL INFILE './tmp2.txt' \
             IGNORE INTO TABLE pdwh_detail.camera_event(Event_Id,\
                                                        Event_Start_Dt,\
                                                        Event_Type_Id);") 

cur.execute("LOAD DATA LOCAL INFILE './tmp4.txt' \
             IGNORE INTO TABLE pdwh_detail.camera_event(Event_Id,\
                                                        Event_Start_Dt,\
                                                        Person_Id,\
                                                        Event_Type_Id);") 

cur.execute("LOAD DATA LOCAL INFILE './tmp3.txt' \
             IGNORE INTO TABLE pdwh_detail.observation_label_related;") 
con.commit()



if con:    
    con.close()

exit(0)   

