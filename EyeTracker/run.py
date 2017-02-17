#!/usr/bin/env python2
# -*- coding: utf-8 -*-
"""
Created on Fri Jan 13 14:40:09 2017
Collect gaze and surface data
@author: gareth
"""

#%% Prepare

     
class eyeTracker():
    """
    Create connections to TCP and eye tracker. 
    Run through each stage automatically with flags.
    
    Automatic processing uses defualts and saves data to disk and self
    Assumes one surface called target
    
    Processsing methods are designed to be externalls callable, but not tested
    yet.
    """
    
    
    def __init__(self, fn='Test.p', ip='127.0.0.1', port='35453', 
                subs=['gaze', 'pupil.0', 'pupil.1', 'surface'], 
                TCPAddr='localhost', TCPPort=52000,
                connectNow=False, startNow=False, processNow=False):

        import time       
        
        # Set propeties and/or defaults
        self.ip = ip
        self.port = port
        self.fn = fn
        self.fnOut = fn + '.mat'
        self.connectNow = connectNow
        self.startNow = startNow
        self.processNow = processNow
        self.TCPPort = TCPPort
        self.TCPAddr = TCPAddr
        
        if not isinstance(subs, list):
            subs=[subs]

        self.subs = subs
        
        self.creationTime = time.time()
        
        # And attemppt to connect
        if self.connectNow:
            eyeTracker.connect(self)
    

    def connect(self):
        import zmq
        # Connect and subscribe to requested messages
        
        # Create ZMQ object
        context = zmq.Context()
        
        # Open REQ Port
        ip = str(self.ip)
        port = str(self.port)
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
        
        for msgs in self.subs:
            sub.setsockopt(zmq.SUBSCRIBE, msgs)
            print 'Subscribed to', msgs
        
            
        self.sub = sub
        
        # Now create TCP server and wait for MATLAB
        eyeTracker.connectTCP(self, addr=self.TCPAddr, port=self.TCPPort)
        
        return(sub)
        
    
    def connectTCP(self, addr='localhost', port=51200):
        import socket
        import time
        
        
        # Create a TCP/IP socket
        sock = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
        sock.setsockopt(socket.SOL_SOCKET, socket.SO_REUSEADDR, 1)
        # Bind the socket to the port
        server_address = (addr, port)
        print('Starting TCP on ' + str(addr) + ':' + str(port))
        sock.bind(server_address)
        
        try:
            # Wait for a connection
            sock.listen(1)
            print('Waiting for MATLAB')
            connection, client_address = sock.accept()
            print('MATLAB connected')
            
            
            data = connection.recv(11)
            
            # When MATLAB connects, send time
            t = repr(time.time())
            connection.send(t)
            
            print('Times swapped')
            self.timeSwapRec = data
            self.timeSwapSend = t
            
            connection.close()
            sock.close()
            print('TCP closed')
            
            if self.startNow:
                eyeTracker.runExp(self)
        except:
            # Any errors? Attempt close and don't continue
            connection.close()
            sock.close()
        
    def runExp(self):
        # Run collection of eye data and pickle to disk
        # Adds time.time() timestamp, no other processing
        # Stop with ABORT    
        import pickle
        import time
        
        self.runExpTime = time.time()
        
        # Open a pickle file to write to
        f = open(self.fn, "wb")
        
        # Run until abort
        print 'Running collection:'
        try:
            while True: 
                # Do minimal processing while collecting
                
                # Get message
                topic,msg = self.sub.recv_multipart(0)
                
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
    
        if self.processNow:
            eyeTracker.process(self)
            
            
    def process(self):
        
        eyeTracker.unpickle(self)
        eyeTracker.surfaceToPandasDF(self)
        
        
    def unpickle(self):
        import pickle
        # Reload pickled data and return in list
        
        # Reopen to read
        f = open(self.fn, 'rb')    
        
        # Loop to load and tabulate saved data
        # Continue until EOF Error
        objs = []
        try:
            pickle.load(f) # Fails if empty
            
            while True:
                try:
                    # OK for now, maybe update for performance later
                    objs.append(pickle.load(f))
                except EOFError:
                    break

            
        except:
            print('Pickle file empty.')
      
        
        self.objs = objs    
        return(objs)
                
    
    def surfaceToPandasDF(self, objs=[], surfs = ['Target'], fnOut=''):
        import pandas as pd
        from msgpack import loads 
        import numpy as np
        import scipy.io as scio
        
        # Convert objs containg gaze information to pandas dataframe and 
        # save a .mat version to disk
        # (Might be better to skip conversion to df as scio.savemat saves dicts)
        
        if len(fnOut)==0:
                fnOut=self.fnOut
            
        if len(objs)==0:
                objs = self.objs
        
        # Get n and track its for reporting
        n = len(objs)
        it = 0.0
        # Prepare df (df.append perf ok?)
        df = pd.DataFrame()
        
        # For each message, process JSON, append as row to df
        for data in objs:
            it+=1
            
            # Extract time stamp
            ts = data['TS']
            # Process message
            msg = loads(data['msg'])
            
            # Find requested surfaces in msg
            # (Just 1 for now)
            filtSurf = msg
            # Get gaze data - may be more than one entry
            gaze = filtSurf['gaze_on_srf']
            gd = {'NP':[], 'on':[]}
            for subGaze in gaze:
                gd['NP'].append(subGaze['norm_pos'])
                gd['on'].append(subGaze['on_srf'])
                # print subGaze['topic'], subGaze['on_srf']
    
            # Average available data
            # 'on_srf'
            # Here no data returns NaN
            onSurf = np.nanmean(gd['on'])
            
            # 'norm_pos'
            # Works for now, but needs updating
            # Need to handle mean on [x,y]
            # Need to handle mean on []
            try:
                NP = np.nanmean(gd['NP'], axis=0)
                if isinstance(NP, np.float64):
                    NP = [0,0]
            except:
                NP = [0,0]
            
            # Report progress
            print str(ts) + ' (' + str(it/n*100) + '%)'
            
            # Get save norm_pos data and TS
            dRow = pd.DataFrame({'TS': ts, 
                          'onSurf' : onSurf,
                          'NP0' : NP[0],
                          'NP1' : NP[1]},
                           index = [int(it)])
            # Append to df
            df = df.append(dRow)
            
        # Save as .mat
        # Can't save pandas df directly, so convert to dict to be saved as 
        # structure    
        dv = {col : df[col].values for col in df.columns.values}   
        
        # Also add time data to dv
        dv['timeSwapRec'] = self.timeSwapRec
        dv['timeSwapSend'] = self.timeSwapSend
        dv['creationTime'] = self.creationTime
        dv['fn'] = self.fn 
        dv['subs'] = self.subs
         
        scio.savemat(fnOut, {'struct': dv})
        
        print('Saved: ' + fnOut)
        self.df = df
        return(df)
    
#%% Run 
%clear
  
## Params
fn = "SyncTest"
port = 50020
TCPAddr = 'localhost'
TCPPort = 52002

# Connect, wait, run, process
eye = eyeTracker(fn=fn, port=port, subs=['surface', 'gaze'],
                 TCPAddr=TCPAddr, TCPPort=TCPPort,
                 connectNow=True, startNow=True, processNow=True)
