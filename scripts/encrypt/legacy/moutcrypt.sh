imagename=$1
rorw=$2
nextloopdevice=`losetup --find`
mountpointname=block.$RANDOM

sudo losetup $nextloopdevice $imagename
#with keyfile
#sudo cryptsetup open $nextloopdevice $imagename --key-file=/tmp/keyfile
#sudo cryptsetup open --readonly $nextloopdevice $imagename --key-file=/tmp/keyfile

sudo cryptsetup open $nextloopdevice $imagename --key-file=/tmp/keyfile

#with header
#sudo cryptsetup open --header=/tmp/luks --header=/tmp/header /dev/loop0 $imagename

#with passphrase
#sudo cryptsetup open /dev/loop3 $imagename

sudo mkdir -p /tmp/$mountpointname

echo "Mount in mnt? default is tmp [yes/no] > "
read mpoint

if [ "$mpoint" == "yes" ]; then
sudo mkdir -p /mnt/zTV/$mountpointname
sudo mount /dev/mapper/$imagename /mnt/zTV/$mountpointname
sudo chown pi:pi /mnt/zTV/$mountpointname
else
sudo mount /dev/mapper/$imagename /tmp/$mountpointname
sudo chown pi:pi /tmp/$mountpointname
fi
echo hit enter when done with $mountpointname
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



