day=$1
prevday=$(($day - 2))

# TURN THIS INTO A SWITCH STATEMENT FOR FUCK'S SAKE
if [ $prevday -ne -1 ] &&
[ $day -ne 3 ] &&
[ $day -ne 5 ]; then
echo day is $day
echo prevday is $prevday

echo error for the moment
exit;

fi

if [ $day -eq 1 ]; then
echo "Day is " $day
exit

fi


echo $day
echo $prevday
cd /mnt/Remote/
mkdir -p /mnt/zTV/enc
mkdir -p /mnt/zTV/enc/Remote/1
mkdir -p /mnt/zTV/enc/Remote/3
mkdir -p /mnt/zTV/enc/Remote/5
mkdir -p /mnt/zTV/enc/changed



function copy_tar_and_checksum() {
#cd /root/bk/xfsDisk3/Backups/Daily.$day/Remote/
echo "Copying files now: "
pwd
rsync -avph ./ /mnt/zTV/enc/Remote/$day/ --delete
cd /mnt/zTV/enc/Remote/$day
for i in *; do tar -cvf "$i".tar "$i"; done
rm md5.$day
for i in *.tar; do md5sum "$i" >> md5.$day; done
}

function comparechecksums() {

cd /mnt/zTV/enc/Remote/$day
echo "Checksumming..."
pwd
rm /tmp/tgchanges
diff -U 0 --suppress-common-lines /mnt/zTV/enc/Remote/$prevday/md5.$prevday /mnt/zTV/enc/Remote/$day/md5.$day | grep "^+[0-9Aa-Zz][0-9A-Za-z]" | awk '{print$2}' > /tmp/tgchanges
if [ ! -s /tmp/tgchanges ]; then
 echo "file is empty"
 echo "Cleaning up and not continuing."
 exit;
else
cp -av /mnt/zTV/enc/Remote/$day/$(cat /tmp/tgchanges) /mnt/zTV/enc/changed/

fi
}

copy_tar_and_checksum
#comparechecksums

function compress_and_encrypt() {
cd /mnt/zTV/enc/changed/
rm *.gpg
rm *.tar.xz
for i in *.tar; do [ $i != "Videos.tar" ] && [ $i != "Wallpapers.tar" ] && xz -vv8 -T 3 $i; done

for i in *.tar; do gpg -vv -r anon --trust-model always -o `basename "$i" .tar`.gpg -e "$i"; done
for i in *.tar.xz; do gpg -vv -r anon --trust-model always -o `basename "$i" .tar.xz`.gpg -e "$i"; done
}


#compress_and_encrypt
