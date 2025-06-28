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

sudo mount /dev/mapper/$imagename /tmp/$mountpointname
sudo chown pi:pi /tmp/$mountpointname
done 

echo Images mounted. 
