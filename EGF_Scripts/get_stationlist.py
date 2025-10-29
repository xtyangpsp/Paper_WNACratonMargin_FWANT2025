import sys
import obspy
import os
import time
import numpy as np
import pandas as pd
from seisgo import downloaders
#########################################################
################ PARAMETER SECTION ######################
#########################################################
# paths and filenames
#if not os.path.isdir(direc): os.mkdir(direc)
down_list  = 'station_wnacraton.txt'
# CSV file for station location info

# download parameters
source='IRIS'                                 # client/data center. see https://docs.obspy.org/packages/obspy.clients.fdsn.html for a list
pressure_chan = [None]				#Added by Xiaotao Yang. This is needed when downloading some special channels, e.g., pressure data. VEL output for these channels.

# targeted region/station information: only needed when use_down_list is False
lamin,lamax,lomin,lomax= 32,49.5,-117.2,-97                # regional box: min lat, max lat, min lon, max lon
chan_list = ["LHZ","BHZ","HHZ"]
#net_list  = ["XO","7A","CN","IM","IU","LD","LM","MU","N4","NM","OH","OK","PE","PN","SS","US","XI","Z9","ZL"]                   # network list
net_list = []
f=open('net_unique_phase1.txt','r')
lines=f.readlines()
f.close()

for line in lines:
    net_list.append(line.strip())

sta_list  = ["*"]                                               # station (using a station list is way either compared to specifying stations one by one)
start_date = "2007_01_01_0_0_0"                               # start date of download
end_date   = "2013_01_01_0_0_0"                               # end date of download
maxseischan = 1                                                  # the maximum number of seismic channels, excluding pressure channels for OBS stations.

##################################################
# we expect no parameters need to be changed below
# assemble parameters used for pre-processing waveforms in downloading
downlist_kwargs = {"source":source, 'net_list':net_list, "sta_list":sta_list, "chan_list":chan_list, \
                    "starttime":start_date, "endtime":end_date, "maxseischan":maxseischan, "lamin":lamin, "lamax":lamax, \
                    "lomin":lomin, "lomax":lomax, "pressure_chan":pressure_chan, "fname":down_list}

########################################################
#################DOWNLOAD SECTION#######################
########################################################
#--------MPI---------
stalist=downloaders.get_sta_list(**downlist_kwargs) # saves station list to "down_list" file
                                              # here, file name is "station.txt"

