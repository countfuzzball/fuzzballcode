#Resize and add blur borders to a video in the style of 9:16 tiktok mobile content

# full
ffmpeg -i input.mp4 -filter_complex "\
[0:v]scale=720:1280,boxblur=luma_radius=20:luma_power=1[blur];\
[0:v]scale=720:1280:force_original_aspect_ratio=decrease[fg];\
[blur][fg]overlay=(W-w)/2:(H-h)/2" \
-c:a copy output_tiktok_720p.mp4

# center crop
ffmpeg -i input.mp4 -filter_complex "\
[0:v]scale=720:1280,boxblur=luma_radius=20:luma_power=1[blur];\
[0:v]crop=in_h*9/16:in_h:(in_w-in_h*9/16)/2:0,scale=540:960[fg];\
[blur][fg]overlay=(W-w)/2:(H-h)/2" \
-c:a copy output_tiktok_ccrop.mp4

