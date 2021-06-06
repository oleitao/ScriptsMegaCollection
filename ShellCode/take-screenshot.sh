#!/bin/bash

# Script for taking a screenshot, uploading, and copying the URL to clipboard
img=$(date '+/tmp/%N.png')
scrot -z "$@" $img >/dev/null 2>&1 || exit
res=$(curl -F c=@$img https://ptpb.pw | awk -F'url:' '{print $2}') && (printf $res | xclip; printf "\a")
notify-send `echo $res`