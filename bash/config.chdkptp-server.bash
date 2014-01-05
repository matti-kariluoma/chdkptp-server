#!/bin/bash
#
# Matti Kariluoma Jan 2014 <matti@kariluo.ma>

CHDKPTP='/home/pi/bin/chdkptp'
DEBUGGING_MESSAGES=false

# where do we create directories to hold the output?
OUT_PREFIX='/home/pi/remoteshoot-output' 

NUM_CAMS=$($CHDKPTP -e'list' | wc -l)

#TODO: how do we configure/collect the serials? go back to left/right files on sd cards?
#TODO: array of serials
CAM0='86AC217FF20F4824ABA79A418D5D669B'
CAM1='20420664CAD94BDDA535E1F926988EEC'

LOG0="$OUT_PREFIX/$CAM0.log"
LOG1="$OUT_PREFIX/$CAM1.log"
