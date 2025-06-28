#!/bin/bash

#Re-written backup script to do "true" incremental backups.


rsync -a /usr/local/bin/diff_backup_test.sh /mnt/Remote/scripts_linux/

#Compare the original/changed files (/mnt/Remote...) with the newest_backup of the files and put any changes into latest_changes. If latest_changes doesn't exist, it'll just copy the whole directory at first
rsync -avirph --compare-dest=/root/bk/Disk2/tmp/bk/newest_backup/ /mnt/Remote/ /root/bk/Disk2/tmp/bk/latest_changes/ --delete

#Next sync the source with newest_backup folder so newest_backup becomes the latest full backup
rsync -avirph /mnt/Remote/ /root/bk/Disk2/tmp/bk/newest_backup/ --delete

#Now do a rotation of the backups
rm -r /root/bk/Disk2/tmp/bk/backup.3

mv /root/bk/Disk2/tmp/bk/backup.2 /root/bk/Disk2/tmp/bk/backup.3
mv /root/bk/Disk2/tmp/bk/backup.1 /root/bk/Disk2/tmp/bk/backup.2

mv /root/bk/Disk2/tmp/bk/latest_changes /root/bk/Disk2/tmp/bk/backup.1
