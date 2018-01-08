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
local_myconfig = json.loads(open('config/local_mysql.json').read())

#Server Connection to MySQL:
import MySQLdb
con = MySQLdb.connect(**myconfig)
cur = con.cursor()

con2 = MySQLdb.connect(**local_myconfig)
cur2 = con2.cursor()

def syncTable(table,tableKey):
    cur2.execute("SELECT COALESCE(MAX(" + tableKey + "),0) \
                  FROM pdwh_detail." + table)
    row2 = cur2.fetchone()
    lastIdSource = row2[0]

    cur.execute("SELECT COALESCE(MAX(" + tableKey + "),0) \
                 FROM pdwh_detail." + table)
    row = cur.fetchone()
    lastIdTarget = row[0]

    if os.path.exists('./tmp_e.txt'): os.remove('./tmp_e.txt')

    cur2.execute("SELECT * INTO OUTFILE './tmp_e.txt' \
                  FROM pdwh_detail." + table + " WHERE " + \
                  tableKey + " > " + xstr(lastIdTarget) + ";")

    cur.execute("LOAD DATA LOCAL INFILE './tmp_e.txt' \
                 IGNORE INTO TABLE pdwh_detail." + table)

    cur2.execute("DELETE FROM pdwh_detail." + table + \
    	         " WHERE " + tableKey + " < " + xstr(lastIdSource) + ";")

    con.commit()
    con2.commit()

syncTable("sensor","Sensor_Id")
syncTable("camera","Camera_Id")
syncTable("entity","Entity_Id")
syncTable("person","Person_Id")
syncTable("observation_label","Label_Id")
syncTable("observation","Observation_Id")
syncTable("camera_event","Event_Id")
syncTable("camera_snapshot","Snapshot_Id")
syncTable("observation_label_related","Observation_label_related_Id")

indir = './snapshots/_tmp'
for root, dirs, filenames in os.walk(indir):
    for f in filenames:
    	os.rename('./snapshots/_tmp/' + f, './snapshots/Google_Gate/' + f)

if con:    
    con.close()

if con2:    
    con2.close()

exit(0)   