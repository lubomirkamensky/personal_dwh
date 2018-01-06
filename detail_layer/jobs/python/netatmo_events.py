#!/usr/bin/python3

import traceback
import sys
import os
from sys import exit
import lnetatmo
import datetime
import time
ts = time.time()

def xstr(s):
    return '' if s is None else str(s)

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

def getRowString(value):
	stringOneRow = value['id'] + '\t' + value['type'] + '\tapi.netatmo.com\tcamera' + '\n'
	return stringOneRow

def loadSuperTable(targetTable,sqlGetloadedItems,allItems,sqlGetlastId):
    try:
        loadedItems = []
        tmp = open('./tmp.txt','w')
        lastId = 0
        
        cur.execute(sqlGetloadedItems)
        rows = cur.fetchall()
        for row in rows:
            loadedItems.append(row[0]) 
       
        newItems = { key:value for key, value in allItems.items() if key not in loadedItems } 
        #print( newItems)

        cur.execute(sqlGetlastId)
        row = cur.fetchone()
        lastId = row[0]

        for value in newItems.values():
            lastId = lastId + 1
            tmp.write('' + xstr(lastId) + '\t' + getRowString(value)) 
    
        tmp.close()
        
        cur.execute("LOAD DATA LOCAL INFILE './tmp.txt' IGNORE INTO TABLE pdwh_detail." + targetTable + ";")  
        con.commit()

    except Exception:
        s = traceback.format_exc()
        serr = "there were errors:\n%s\n" % (s)
        sys.stderr.write(serr)         

def loadSubTable(targetTable,allItems,nameKey,sqlGetSubTableItems):
	names = { value['id']: value[nameKey] for key, value in allItems.items()  } 
    
	tmp = open('./tmp.txt','w')
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
cur.execute("SELECT Sensor_Id,Sensor_Source_Cd \
             FROM pdwh_detail.sensor \
             WHERE Target_Table = 'camera' AND Source_Name = 'api.netatmo.com';")
rows = cur.fetchall()
for row in rows:
    camera[row[1]] = [row[0],0]

cur.execute("SELECT s.Sensor_Source_Cd,COALESCE(MAX(o.Observation_Timestamp),0) \
             FROM  pdwh_detail.observation o \
             INNER JOIN pdwh_detail.sensor s ON o.Sensor_Id = s.Sensor_Id \
             WHERE s.Target_Table = 'camera' AND s.Source_Name = 'api.netatmo.com' \
             GROUP BY 1")
rows = cur.fetchall()
for row in rows:
    camera[row[0]][1] = row[1]

cur.execute("SELECT COALESCE(MAX(Observation_Id),0) \
             FROM pdwh_detail.observation")
row = cur.fetchone()
lastId = row[0]

cur.execute("SELECT COALESCE(MAX(Observation_Id),0) \
             FROM pdwh_detail.observation")
row = cur.fetchone()
lastId = row[0]

tmp = open('./tmp.txt','w')
tmp2 = open('./tmp2.txt','w')
tmp3 = open('./tmp3.txt','w')
tmp4 = open('./tmp4.txt','w')

for i in homeData.events.keys():
    xEvents = homeData.events[i]

    p1 = [ [value['time'],value['type'],value['person_id']] if 'person_id' in value.keys() 
            else [value['time'],value['type'],set([i['type'] for i in value['event_list']])] 
            if 'event_list' in value.keys() else [value['time'],value['type']] 
            for key, value in xEvents.items() if key > camera[i][1] ]
    
    

    for x in p1:
        lastId = lastId + 1
        tmp.write(xstr(lastId)  + '\t' + xstr(x[0]) + '\t' + xstr(camera[i][0]) + '\t' +  \
                  'camera_event' + '\n')

        if x[1] == 'person': 
            tmp4.write(xstr(lastId)  + '\t' + \
                       datetime.datetime.fromtimestamp(x[0]).strftime('%Y-%m-%d %H:%M:%S') + '\t' + \
                       xstr(person[x[2]]) + '\t' + \
                       xstr(event_type[x[1]]) + '\n')
        else:
            tmp2.write(xstr(lastId)  + '\t' + \
                       datetime.datetime.fromtimestamp(x[0]).strftime('%Y-%m-%d %H:%M:%S') + '\t' + \
                       xstr(event_type[x[1]]) + '\n')

        if x[1] == 'outdoor': 
            for y in x[2]:
                tmp3.write(xstr(lastId)  + '\t' + xstr(label[y]) + '\n')
    
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

