#!/bin/bash
# This runs in Crontab to check that the wifi is working.  If it is faulty it will 
# firstly restart wifi and check all is running well.  If not, the script will reboot the PI
# Any checks and reboots are stored as actions in txt files in /home/pi/
# Dominic 29/1/2020

# Lines below are to get the date and time variables ready
BASHDATE=`date +"%b %d, %Y"`
BASHTIME=`date +" %T"`
# Start of code
ping -c1 8.8.8.8 > /dev/null
if [ $? != 0 ]
then
#	WiFi is down so going into the next phase of this file to check, reset and reboot too if necessary
	echo WiFi all bad, restarting it on ${BASHDATE} at: ${BASHTIME} >> /home/pi/WiFi_bad.txt
	sudo ifconfig wlan0 down
	sleep 5
#	Restarting WIFI if needed
	sudo ifconfig wlan0 up
	sleep 180
	sleep 20
#	Re-pinging after wifi re-start
	ping -c1 8.8.8.8 > /dev/null
#	If Ping fails the PI will restart
	if [ $? != 0 ] && [ ! -f /tmp/bkup.AC ]
	then
		echo WiFi all bad, restarting the PI on ${BASHDATE} at: ${BASHTIME} >> /home/pi/WiFi_bad_reboot.txt
		sleep 5
		sudo reboot
	fi

else
# If all is good this is written to a text file.  I'll reduce this to only having one line kept becuase later
	true;
	echo wifi is up on ${BASHDATE} at ${BASHTIME} >> /home/pi/WIFI.txt
fi
