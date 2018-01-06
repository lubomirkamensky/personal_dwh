#!/usr/bin/python3

from sys import exit
import datetime
import time
ts = time.time()

import json
myconfig = json.loads(open('config/mysql.json').read())

#Server Connection to MySQL:
import MySQLdb
con = MySQLdb.connect(**myconfig)
cur = con.cursor()



exit(0)   

