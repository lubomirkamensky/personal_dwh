#!/usr/bin/python3

import traceback
import sys
import os
from sys import exit
import lnetatmo
import datetime
import time
ts = time.time()

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
        tmp = open('tmp.txt','w')
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
            tmp.write('' + str(lastId) + '\t' + getRowString(value)) 
    
        tmp.close()
        
        cur.execute("LOAD DATA LOCAL INFILE '/home/luba/tmp.txt' IGNORE INTO TABLE pdwh_detail." + targetTable + ";")  
        con.commit()

    except Exception:
        s = traceback.format_exc()
        serr = "there were errors:\n%s\n" % (s)
        sys.stderr.write(serr)         

def loadSubTable(targetTable,allItems,nameKey,sqlGetSubTableItems):
	names = { value['id']: value[nameKey] for key, value in allItems.items()  } 
    
	tmp = open('tmp.txt','w')
	cur.execute(sqlGetSubTableItems)
	rows = cur.fetchall()
	for row in rows:
		tmp.write('' + str(row[1]) + '\t' + names[row[0]] + '\n')
    
	tmp.close()
        
	cur.execute("LOAD DATA LOCAL INFILE '/home/luba/tmp.txt' IGNORE INTO TABLE pdwh_detail." + targetTable + ";")  
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
loadSubTable('person',allItems,'pseudo',

	sqlGetSubTableItems)

# Observation > Event

# movement category human
# outdoor label human, vehicle, animal

# event_type, event_category, label
# observation > event > snapshot
# dict: type, person, camera
# last timestamp for each camera
# last observation id
event_type = {'Person':11,'Movement':12,'Outdoor':13}

label = {'Human':1,'Vehicle':2,'Animal':3}

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
	camera[row[1]] = [].append(row[0])

cur.execute("SELECT s.Sensor_Source_Cd,MAX(o.Observation_Timestamp) \
             FROM  pdwh_detail.observation o \
             INNER JOIN pdwh_detail.sensor s ON o.Sensor_Id = s.Sensor_Id \
             WHERE s.Target_Table = 'camera' AND s.Source_Name = 'api.netatmo.com'")
rows = cur.fetchall()
for row in rows:
	camera[row[0]].append(row[1]) 

cur.execute("")
row = cur.fetchone()
lastId = row[0]

for i in homeData.events.keys():
	xEvents = homeData.events[i]
	p1 = [ [value['time'],value['type'],value['person_id']] if 'person_id' in value.keys() 
	        else [value['time'],value['type'],set([i['type'] for i in value['event_list']])] 
	        if 'event_list' in value.keys() else [value['time'],value['type']] 
	        for key, value in xEvents.items() if key > 1513751948 ]
	print(i)
	print(p1)




if con:    
    con.close()

exit(0)   

