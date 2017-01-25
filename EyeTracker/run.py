#!/usr/bin/env python2
# -*- coding: utf-8 -*-
"""
Created on Fri Jan 13 14:40:09 2017
Collect gaze and surface data
@author: gareth
"""

#%% Prepare

import zmq
from msgpack import loads  
import time
import pandas as pd
import pickle
import scipy.io as scio
import numpy as np
import matplotlib.pyplot as plt


def connect(ip='127.0.0.1', port='35453', subs=['gaze', 'pupil.0']):
    # Connect and subscribe to requested messages
    
    # Create ZMQ object
    context = zmq.Context()
    
    # Open REQ Port
    ip = str(ip)
    port = str(port)
    adrStr = "tcp://%s:%s" %(ip, port)
    
    print 'Attempting to connect to:', adrStr
    req = context.socket(zmq.REQ)
    req.connect(adrStr)
    
    # Ask for the sub port
    print '   Requesting sub port'
    req.send_string('SUB_PORT')
    subPort = req.recv(0)
    
    # open a sub port to listen to pupil
    print '   Connecting to sub port:', subPort
    sub = context.socket(zmq.SUB)
    sub.connect("tcp://%s:%s" %(ip, int(subPort)))
    print 'Connected'
    
    # Subscribe to messages
    if not isinstance(subs, list):
        subs=[subs]
    for msgs in subs:
        sub.setsockopt(zmq.SUBSCRIBE, msgs)
        print 'Subscribed to', msgs
        
    return(sub)
    
    
def runExp(fn, sub):
    # Run collection of eye data and pickle to disk
    # Adds time.time() timestamp, no other processing
    # Stop with ABORT    

    # Open a pickle file to write to
    f = open(fn,"wb")
    
    # Run until abort
    print 'Running collection:'
    try:
        while True: 
            # Do minimal processing while collecting
            
            # Get message
            topic,msg =  sub.recv_multipart()
            
            # Convert to dict and add timestamp
            t = time.time()
            msg = {'TS':t, 'msg':msg}

            # Dump to pickle file
            pickle.dump(msg, f)
            print "Collected at " + str(t)
            
    except: # Catch abort
        print 'Stopped' 
        
        # Close open file    
        f.close()      

  
#%% Run 
  
## Params
fn = "SurfaceTest4.p"
port = 50020

## Run
sub = connect(port=port, subs='surface')
runExp(fn, sub)
