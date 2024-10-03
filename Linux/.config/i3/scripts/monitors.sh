#!/bin/bash
###########################################################################
 # Name: monitors.sh
 # Author: Adam Camilli <AdamOCamilli@github.com>
 # Description: Adjust i3 monitors
 # Date: 03/18/2024
###########################################################################

# Error/warning strings for logging
error_str="ERROR: $0"
warning_str="WARNING: $0"

monitors=($(xrandr --listactivemonitors | awk '/\+/ {print $4}'))

# Ideally manage only with autorandr
xsct_brightness=1
xsct_temperature=3500
#xsct ${xsct_temperature} ${xsct_brightness}

