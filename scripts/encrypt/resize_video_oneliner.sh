# Resizes input file to a height divisible by 2 with a width of 720
ffmpeg -i "$1" -vf "scale=trunc(oh*a/2)*2:180" -r 10 -c:a copy resize.mp4

##for i in *.mov; do ffmpeg -i $i -filter:v scale="trunc(oh*a/2)*2:720" -c:a copy `basename $i .mov`-720.mov; done
#Looped version
