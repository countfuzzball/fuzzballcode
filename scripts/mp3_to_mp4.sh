To convert audio mp3 to MP4 by ffmpeg, use the following command

ffmpeg -f lavfi -i color=c=black:s=1280x720:r=5 -i audio.mp3 -crf 0 -c:a copy -shortest output.mp4
