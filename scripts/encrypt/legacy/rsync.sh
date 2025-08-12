#!/bin/bash
exit
acnas=/mnt
acdisk1=/root/bk/xfsDisk3
acdisk2=/root/bk/xfsDisk4
mount > /tmp/mount.out

touch /tmp/bkup.AC

if grep -q xfsDisk3 /tmp/mount.out; then
 echo Dailies disk mounted. Proceeding.
else
echo cannot find xfsDisk3 in mount;
 exit;
fi

#First argument to the script
arg=$1;

if [ "$arg" = "daily" ]; then
 if grep -q mnt /tmp/mount.out; then
   echo Network drive mounted.
  else
   exit;
 fi
 mkdir -p /Storage
 mkdir -p /Storage/Disk1
 mkdir -p /Storage/Disk2
 mkdir -p /Storage/xfsDisk3
 mkdir -p /Storage/xfsDisk4
 mkdir -p $acnas/Remote/scripts_linux
 #rsync -a /usr/local/bin/rsync.sh $acnas/Remote/scripts_linux/
 #rsync -a /etc/crontab $acnas/Remote/scripts_linux/
 #rsync -a /etc/fstab $acnas/Remote/scripts_linux/
 chmod -Rv 777 $acnas/Remote/scripts_linux/
 echo synced scripts
 mount --bind $acdisk1 /Storage/Disk1
 mount -o remount,ro,bind $acdisk1 /Storage/Disk1
else
echo continuing.
fi

case $arg in
daily)
bash /mnt/Remote/scripts_linux/rsync.sh rotatedaily
mkdir -p $acdisk1/Backups
mkdir -p $acdisk1/Backups/Logs
mkdir -p $acdisk1/Backups/Daily.1
mkdir -p $acdisk1/Backups/Daily.2
mkdir -p $acdisk1/Backups/Daily.3
mkdir -p $acdisk1/Backups/Daily.4
mkdir -p $acdisk1/Backups/Daily.5
mkdir -p $acdisk1/Backups/Daily.6
mkdir -p $acdisk1/Backups/Daily.7

echo daily backups
 (time rsync -viarph --exclude='tmp/docker/'  --exclude='zTV/' --link-dest=$acdisk1/Backups/Daily.2 $acnas/ $acdisk1/Backups/Daily.1/ --delete) > $acdisk1/Backups/Logs/logs-`date +%d-%m-%Y`.txt 2>&1
 #(time rsync -viarph --exclude='QB/' --exclude='tmp/docker/'  --exclude='zTV/' --link-dest=$acdisk1/Backups/Daily.2 $acnas/ $acdisk1/Backups/Daily.1/ --delete) > $acdisk1/Backups/Logs/logs-`date +%d-%m-%Y`.txt 2>&1
cat $acdisk1/Backups/Logs/logs-`date +%d-%m-%Y`.txt | mail -s "`date +%d-%m-%Y` daily BKUP" pi@btnas
sleep 5
rm /tmp/bkup.AC
;;

rotatedaily)
echo daily rotations
#Compare for days 3-7 the previous day's backup files and only copy changed files when rotating. Also replaces day 7's files with hardlinks to day 6's (and so on) if they're the exact same size/modified time.
{ time rsync -arpv --link-dest=$acdisk1/Backups/Daily.6 $acdisk1/Backups/Daily.6/ $acdisk1/Backups/Daily.7 --delete ; }
{ time rsync -arpv --link-dest=$acdisk1/Backups/Daily.5 $acdisk1/Backups/Daily.5/ $acdisk1/Backups/Daily.6 --delete ; }
{ time rsync -arpv --link-dest=$acdisk1/Backups/Daily.4 $acdisk1/Backups/Daily.4/ $acdisk1/Backups/Daily.5 --delete ; }
{ time rsync -arpv --link-dest=$acdisk1/Backups/Daily.3 $acdisk1/Backups/Daily.3/ $acdisk1/Backups/Daily.4 --delete ; }
{ time rsync -arpv --link-dest=$acdisk1/Backups/Daily.2 $acdisk1/Backups/Daily.2/ $acdisk1/Backups/Daily.3 --delete ; }
echo copying daily 1 to daily 2.
{ time rsync -arpvh --link-dest=$acdisk1/Backups/Daily.1 $acdisk1/Backups/Daily.1/ $acdisk1/Backups/Daily.2 --delete ; }
#{ time rsync -arpvh $acdisk1/Backups/Daily.1/ $acdisk1/Backups/Daily.2 --delete ; }

;;
weekly)
if grep -q xfsDisk4 /tmp/mount.out; then
  echo  Disk 2 is mounted, we can do the weekly backup.
 else
exit;
fi

bash /mnt/Remote/scripts_linux/rsync.sh rotateweekly
 mount --bind $acdisk2 /Storage/Disk2
 mount -o remount,ro,bind $acdisk2 /Storage/Disk2
mkdir -p $acdisk2/Backups
mkdir -p $acdisk2/Backups/Logs
mkdir -p $acdisk2/Backups/Weekly.1
mkdir -p $acdisk2/Backups/Weekly.2
mkdir -p $acdisk2/Backups/Weekly.3
echo weekly backups
(time rsync -vaiprh --delete $acdisk1/Backups/Daily.1/ $acdisk2/Backups/Weekly.1/) > $acdisk2/Backups/Logs/logs-`date +%d-%m-%Y`.txt 2>&1
cat $acdisk2/Backups/Logs/logs-`date +%d-%m-%Y`.txt | mail -s "`date +%d-%m-%Y` weekly BKUP" pi@btnas
sleep 5
rm /tmp/bkup.AC
;;

rotateweekly)
echo weekly rotations
rsync -airpvh $acdisk2/Backups/Weekly.2/ $acdisk2/Backups/Weekly.3 --delete
rsync -airpvh $acdisk2/Backups/Weekly.1/ $acdisk2/Backups/Weekly.2 --delete
;;

*)
exit
esac

# This file should go in /usr/local/bin.
#DONE: Figure out how to use --link-dest=. stack exchange recommends rsync -av --link-dest=/path_to_previous_backup source/ /path_to_this_backup
#TODO: Stop mountpoint spam when running Daily and Weekly several times.
#Temperature command for raspberry pi: vcgencmd measure_temp
#rsync notes:
# -a is Archive. Preserves owner, permissions and most importantly the timestamps.
# use --size-only in conjunction with -a to only copy across the timestamps of existing copies of data at the target location.

#Old test commands
#rsync --exclude lost+found -n -h -a -v -c --delete /home/pi/Storage/Disk1/Files/ /home/pi/Storage/Disk2/Files
#Except when rotating to the 2nd day, keep a full copy of the previous day's backup.
#{ time rsync -apv $acdisk1/Backups/Daily.1/ $acdisk1/Backups/Daily.2 --delete ; }
