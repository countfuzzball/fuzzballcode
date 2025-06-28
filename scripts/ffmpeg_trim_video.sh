#Seek to 5 minutes in the input file and only output the next 30 seconds. i.e 5:00 minutes to 5:30 minutes
# use codec copy (-c:v copy) which does a straight 1:1 copy when trimming to files of the same type, otherwise the default behaviour is a re-encode, which lowers quality.
ffmpeg -ss 00:5:00 -t 30 -i input.wmv -c:v copy  output1.wmv


#can also use -to option to specify a specific time code like "-to 00:5:30" for seek to 5 minutes, and trim to the next 30 seconds.
#additional info from man page: https://trac.ffmpeg.org/wiki/Seeking
