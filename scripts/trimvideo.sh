#!/bin/bash
#trim a video with ffmpeg -ss is the start timecode. -to is the end timecode. i.e 17 minutes 20 seconds, to 18 minutes 40 seconds:

ffmpeg -ss 00:17:20 -to 00:18:40 -i input.mp4 -c copy output.mp4
