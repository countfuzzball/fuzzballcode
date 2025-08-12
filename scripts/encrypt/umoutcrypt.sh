echo hit enter when done.
echo specify if you used ztv or not. yes or no: 
read mpoint


if [ "$mpoint" == "yes" ]; then
sudo umount /mnt/zTV/*.crypt.*
sudo cryptsetup close $imagename
sudo losetup --detach $nextloopdevice
sudo rmdir /mnt/zTV/$mountpointname
else
sudo umount /tmp/*.crypt.*
for imagename in `basename -a /tmp/*.crypt.*`; do

baseimage=`echo $imagename | sed -e s#.crypt.*###g`
echo closing crypt volume $baseimage
sudo cryptsetup close $baseimage

detachdevicefull=`losetup --list -n -O NAME,BACK-FILE | grep $baseimage`


detachdeviceimage=`losetup --list -n -O BACK-FILE | grep $baseimage`
detachdevice=`echo $detachdevicefull | cut -c 1-11`

echo detachfulllist is $detachdevicefull

DDbaseimage=`basename -a $detachdeviceimage`

echo Detaching: $DDbaseimage on $detachdevice
sudo losetup --detach $detachdevice
sync;
sync;
sudo rmdir /tmp/*.crypt.*
done
fi



# cryptsetup examples
#with keyfile
#sudo cryptsetup open $nextloopdevice $imagename --key-file=/tmp/keyfile
#sudo cryptsetup open --readonly $nextloopdevice $imagename --key-file=/tmp/keyfile

#with header
#sudo cryptsetup open --header=/tmp/luks --header=/tmp/header /dev/loop0 $imagename

#with passphrase
#sudo cryptsetup open /dev/loop3 $imagename

