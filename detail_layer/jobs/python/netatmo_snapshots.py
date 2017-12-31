#!/usr/bin/python3

from sys import exit
import lnetatmo
import datetime
import time
ts = time.time()

import json
config = json.loads(open('config/netatmo.json').read())
# Netatmo Authenticate (see authentication in documentation)
authorization = lnetatmo.ClientAuth(**config)

# Gather Home information (available cameras and other infos)
homeData = lnetatmo.HomeData(authorization)

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
    except:
        pass  

writeSnapshot("Prizemi")
writeSnapshot("VCHOD")
writeSnapshot("Zahrada")


exit(0)   

