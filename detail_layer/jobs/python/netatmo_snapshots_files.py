#!/usr/bin/python3

from sys import exit
import sys
from multiprocessing import Pool
import lnetatmo
import datetime
import time
import traceback
import json
ts = time.time()

#This line opens a log file
log = open("log_" + sys.argv[1] + ".txt", "w")

config = json.loads(open('config/netatmo.json').read())
# Netatmo Authenticate (see authentication in documentation)
authorization = lnetatmo.ClientAuth(**config)

# Gather Home information (available cameras and other infos)
try:
    homeData = lnetatmo.HomeData(authorization)
except Exception:
    traceback.print_exc(file=log)
    log.close()  


def writeSnapshot(MY_CAMERA):
    try:
        # Request a snapshot from the camera
        snapshot = homeData.getLiveSnapshot( camera=MY_CAMERA )

        # If all was Ok, I should have an image, if None there was an error
        if not snapshot :
            # Decide what to do with an error situation (alert, log, ...)
            exit(1)

        # Save the snapshot in a file
        snapshotPath = "./snapshots/" + MY_CAMERA + "/" + str(round(time.time())) + ".jpg"
        with open(snapshotPath, "wb") as f: f.write(snapshot)
    except Exception:
        traceback.print_exc(file=log)
        log.close()  

# we will execute this cript each minute
def cameraLoop(name):
    while (time.time() < ts + 86395):
        start = time.time()
        writeSnapshot(name)
        if time.time() - start < 6:
            time.sleep(6-(time.time() - start))

cameraLoop(sys.argv[1])

exit(0)   

