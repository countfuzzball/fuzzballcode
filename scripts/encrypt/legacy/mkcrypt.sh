imagename=$1
nextloopdevice=`losetup --find`

#dd if=/dev/zero of=$imagename bs=1G count=4 iflag=fullblock
#dd if=/dev/zero of=$imagename bs=1100M count=3 iflag=fullblock

fallocate -l 9760M $imagename

#if using with header
#sudo cryptsetup -h sha512 -s 512 -i 8000 --use-urandom -y luksFormat $imagename --header=/tmp/header
#Use a keyfile only
sudo cryptsetup -h sha512 -s 512 -i 8000 --use-urandom -y luksFormat $imagename --key-file=/tmp/keyfile


sudo losetup $nextloopdevice $imagename
#sudo cryptsetup open --header=/tmp/header /dev/loop0 $imagename
sudo cryptsetup open --key-file=/tmp/keyfile $nextloopdevice $imagename
sudo mkfs.ext4 -M 0 /dev/mapper/$imagename
sudo cryptsetup close $imagename
sudo losetup --detach $nextloopdevice
