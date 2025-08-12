#!/bin/bash
acnas=/mnt
mount > /tmp/mount.out

touch /tmp/bkup.AC

#First argument to the script
arg=$1;

if [ "$arg" = "daily" ]; then
 if grep -q mnt /tmp/mount.out; then
   echo Network drive mounted.
  else
   exit;
 fi
# mount --bind $acdisk1 /Storage/Disk1
# mount -o remount,ro,bind $acdisk1 /Storage/Disk1
else
echo continuing.
fi

case $arg in
daily)
rm /tmp/bkup.AC

;;

weekly)
echo weekly backups

rsync -avph --exclude='zTV/' -e 'ssh -i /mnt/grimoire/Local/keyforbackups.privkey' /mnt/grimoire/ pi@roompi.local:/mnt/sanctum/Backups/Weekly.1/ --progress --delete
#(time rsync -vaiprh --delete $acdisk1/Backups/Daily.1/ $acdisk2/Backups/Weekly.1/) > $acdisk2/Backups/Logs/logs-`date +%d-%m-%Y`.txt 2>&1
#cat $acdisk2/Backups/Logs/logs-`date +%d-%m-%Y`.txt | mail -s "`date +%d-%m-%Y` weekly BKUP" pi@btnas
sleep 5

rm /tmp/bkup.AC
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
