#!/bin/bash
#
# Script to preview CSGO shadowplay replays and functionality to add information to them
# 

# Get the date of the newest video file
dateStr=$(ls -tr *.DVR.mp4 | awk '{print $4}' | tail -n 1);

# Loop through all mp4 files in the directory newest first
for file in *$dateStr*.mp4; do
   echo "Found file: $file";

   # Get the time of the video file
   timeStr=$(echo "${file}" | sed 's/.DVR/ /g' | awk '{print $6}');

   # Get duration of video
   filetime=$(ffmpeg -i "${file}" 2>&1 | grep Duration | cut -d ' ' -f 4 | sed s/,//);
   min="${filetime:3:2}";
   sec="${filetime:6:2}";

   # Create a start time for vlc (duration-20sec)
   starttime=$(echo "${sec} + ( ${min} * 60 ) - 20" | bc);

   # Open video using vlc at starttime
   vlc --start-time=${starttime} "${file}" >/dev/null;

   # Ask for a name
   read -p "Information: " newNameRaw

   # Set new name
   newName=$(echo "csgo_${dateStr}-${timeStr}-${newNameRaw}.mp4" | sed 'y/\ åäö/\.aao/');

   # Rename file
   mv "${file}" "${newName}"
done

# Remove files that was flagged to get removed
rm -vf *tabort*
rm -vf *remove*

