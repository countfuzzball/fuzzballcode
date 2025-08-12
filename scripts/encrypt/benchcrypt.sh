#!/bin/bash

echo Starting benchmark.

echo Creating 1GB file: 

SIZE=1024


dd if=/dev/urandom of=testfile bs=1M count=1024 status=progress

echo Testing encryption write speed
echo " "
echo " "

START_TIME_ENCRYPT=$(date +%s.%N)
pv testfile | gpg --trust-model always -e -r anon -o test.gpg
END_TIME_ENCRYPT=$(date +%s.%N)

# Calculate elapsed time and throughput
ELAPSED_TIME=$(echo "$END_TIME_ENCRYPT - $START_TIME_ENCRYPT" | bc)
THROUGHPUT=$(echo "scale=2; $SIZE / $ELAPSED_TIME" | bc)

echo "--- Encryption throughput: $THROUGHPUT MB/s ---"
echo " "
echo " "


echo --- Testing decryption write speed ---
START_TIME_DECRYPT=$(date +%s.%N)
pv test.gpg | gpg --decrypt -o foo
END_TIME_DECRYPT=$(date +%s.%N)



# Calculate elapsed time and throughput
ELAPSED_TIME=$(echo "$END_TIME_DECRYPT - $START_TIME_DECRYPT" | bc)
THROUGHPUT=$(echo "scale=2; $SIZE / $ELAPSED_TIME" | bc)

echo "--- Encryption throughput: $THROUGHPUT MB/s ---"
echo " "
echo " "

sleep 6

echo DONE!

rm test.gpg foo testfile
