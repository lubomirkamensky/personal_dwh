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

sqlGetSnapshotFiles = "SELECT File_Name \
                       FROM pdwh_detail.camera_snapshot \
                       ORDER BY Snapshot_Id desc LIMIT 500;"

cur.execute(sqlGetSnapshotFiles)
rows = cur.fetchall()
dbSnapshotFiles = []
for row in rows:
    dbSnapshotFiles.append(row[0])
    
if con:    
    con.close()

dirSnapshotFiles = []
indir = './snapshots/Google_Gate' 
for root, dirs, filenames in os.walk(indir):
    for f in filenames:
        dirSnapshotFiles.append(f) 

filenames = list(set(dbSnapshotFiles) & set(dirSnapshotFiles))

for f in filenames:
    os.remove(indir + '/' + f) 

exit(0)   
