#!/bin/bash

#Rsync local TLDP copy against Ibiblio's mirror and then tar up the directory

cd /mnt/Apache/www/Archives/MIRRORS/
/usr/bin/rsync -rhlptv --delete ftp.ibiblio.org::ldp_mirror LDP/

case $1 in

mon)
time tar -cvf LDP-latest-mon.tar LDP/
;;
wed)
time tar -cvf LDP-latest-wed.tar LDP/
;;
fri)
time tar -cvf LDP-latest-fri.tar LDP/
;;
esac
