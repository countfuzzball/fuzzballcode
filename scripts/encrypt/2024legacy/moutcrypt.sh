imagename=$1
rorw=rw


for imagename in "$@"; do
 nextloopdevice=`losetup --find`
 mountpointname="$imagename".crypt.$RANDOM
 mpoint=zilch
 sudo losetup $nextloopdevice $imagename

echo MOUNTING $imagename using $nextloopdevice at $mountpointname

 if [ "$rorw" == "rw" ]; then
 echo Opening image readwrite
 sudo cryptsetup open $nextloopdevice $imagename --key-file=/tmp/keyfile --perf-no_read_workqueue --perf-submit_from_crypt_cpus --perf-no_write_workqueue
 else
 echo Opening image readonly
 sudo cryptsetup open --readonly $nextloopdevice $imagename --key-file=/tmp/keyfile --perf-no_read_workqueue --perf-submit_from_crypt_cpus --perf-no_write_workqueue
 fi

 sudo mkdir -p /tmp/$mountpointname
 echo starting mount $imagename
 echo 
#echo "Mount in mnt? default is tmp [yes/no] > "
#read mpoint
mpoint=no

if [ "$mpoint" == "yes" ]; then
sudo mkdir -p /mnt/zTV/$mountpointname
sudo mount /dev/mapper/$imagename /mnt/zTV/$mountpointname
sudo chown pi:pi /mnt/zTV/$mountpointname
echo mounting mounting mounting
else
sudo fsck /dev/mapper/$imagename
sudo mount /dev/mapper/$imagename /tmp/$mountpointname
sudo chown pi:pi /tmp/$mountpointname
fi

done 

echo Images mounted. 
exit

echo hit enter when done.
read h




if [ "$mpoint" == "yes" ]; then
sudo umount /mnt/zTV/$mountpointname
sudo cryptsetup close $imagename
sudo losetup --detach $nextloopdevice
sudo rmdir /mnt/zTV/$mountpointname
else
sudo umount /tmp/$mountpointname
sudo cryptsetup close $imagename
sudo losetup --detach $nextloopdevice
sudo rmdir /tmp/$mountpointname
fi



# cryptsetup examples
#with keyfile
#sudo cryptsetup open $nextloopdevice $imagename --key-file=/tmp/keyfile
#sudo cryptsetup open --readonly $nextloopdevice $imagename --key-file=/tmp/keyfile

#with header
#sudo cryptsetup open --header=/tmp/luks --header=/tmp/header /dev/loop0 $imagename

#with passphrase
#sudo cryptsetup open /dev/loop3 $imagename

