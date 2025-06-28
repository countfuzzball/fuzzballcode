#!/bin/sh

j=0
# convert options
pic="-resize 1280x720 -background black -gravity center -extent 1280x720"

# loop over the images
for i in *jpg; do
#for i in `ls *jpg | sort -R`; do
 echo "Convert $i"
 convert $pic "$i" "jpgcfcon-$j.jpg"
 j=`expr $j + 1`
done

# now generate the movie
mp3="file.mp3"
echo "make movie"
#-r is FPS.  -framerate is framerate-percentage
ffmpeg -framerate 2.0 -i jpgcfcon-%d.jpg -c:v libx264 -r 12 -pix_fmt yuv420p -s 1280x720 -shortest out.mp4
#ffmpeg -framerate 3 -i jpgcfcon-%d.jpg -i $mp3 -acodec copy -c:v libx264 -r 30 -pix_fmt yuv420p -s 1920x1080 -shortest out.mp4
rm jpgcfcon*
