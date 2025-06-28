#Find all files and run them through md5sum, then sort the resulting output starting from after the 32 character md5sum.
time find . -type f -exec md5sum {} + | sort -k 1.33 > ./md5sums.txt

