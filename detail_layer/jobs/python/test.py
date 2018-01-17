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


# Netatmo Authenticate (see authentication in documentation)
authorization = lnetatmo.ClientAuth(**config)

# Gather Home information (available cameras and other infos)
homeData = lnetatmo.HomeData(authorization)


#print(homeData.cameraUrls(cid='70:ee:50:28:14:52')[0])


from urllib import request
def saveFromUrl(cameraKey,cameraDict,snapshoDict):
    if 'id' in snapshoDict[1].keys():
        url = "https://api.netatmo.com/api/getcamerapicture?image_id=" \
        + snapshoDict[1]['id'] + "&key=" + snapshoDict[1]['key']
    elif 'filename' in snapshoDict[1].keys():
        url = homeData.cameraUrls(cid=cameraKey)[0] + '/' + snapshoDict[1]['filename']
    else
        url = ""

    snapshotPath = "./snapshots/" + xstr(cameraDict[cameraKey][2]) + "/" + xstr(timestamp) + ".jpg"
    f = open(snapshotPath, 'wb')
    f.write(request.urlopen(url).read())
    f.close()

#print(homeData.events)

for i in homeData.events.keys():
    xEvents = homeData.events[i]

    p1 = [ [  value['time'],
              value['type'],
              value['person_id'],
              value['snapshot']] 
            if 'snapshot' in value.keys() and 'person_id' in value.keys() 
            else [
                  value['time'],
                  value['type'],
                  value['snapshot']]
            if 'snapshot' in value.keys()
            else [value['time'],
                  value['type'],
                  value['person_id']] 
            if 'person_id' in value.keys() 
            else [value['time'],
                  value['type'],
                  set([i['type'] for i in value['event_list']]),
                  [[i['time'],i['snapshot']] if 'snapshot' in i.keys() else [] for i in value['event_list'] ]] 
            if 'event_list' in value.keys() 
            else [value['time'],
                  value['type']] 
            for key, value in xEvents.items()  ]


    for x in p1:

        if x[1] == 'person' and len(x) == 4: 
            for y in x[3]:
                saveFromUrl(i,camera,y)
        elif x[1] == 'movement' and len(x) == 3:
            for y in x[2]:
                saveFromUrl(i,camera,y)
        elif x[1] == 'outdoor' and len(x) == 4: 
            for y in x[3]:
                saveFromUrl(i,camera,y)

