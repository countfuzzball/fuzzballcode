#!/bin/bash

# Check if a file name is provided
if [ "$#" -ne 1 ]; then
    echo "Usage: $0 <video_file>"
    exit 1
fi

VIDEO_FILE="$1"

# Check if the video file exists
if [ ! -f "$VIDEO_FILE" ]; then
    echo "Error: File does not exist."
    exit 1
fi

# Extract video resolution
RESOLUTION=$(ffprobe -v error -select_streams v:0 -show_entries stream=width,height -of csv=s=x:p=0 "$VIDEO_FILE")
WIDTH=$(echo $RESOLUTION | cut -d'x' -f1)
HEIGHT=$(echo $RESOLUTION | cut -d'x' -f2)

# Determine the scaling parameters
if [ "$HEIGHT" -gt 720 ]; then
    SCALE="-vf scale=-1:720"
else
    SCALE=""
fi

# Get the duration of the video in seconds
DURATION=$(ffmpeg -i "$VIDEO_FILE" 2>&1 | grep "Duration" | awk '{print $2}' | tr -d , | awk -F: '{print ($1 * 3600) + ($2 * 60) + $3}')

# Calculate time increments
declare -a PERCENTAGES=(0.125 0.25 0.375 0.50 0.625 0.75 0.875 0.99)
declare -a FILES=()

# Generate thumbnails at each percentage of the total duration
for i in "${!PERCENTAGES[@]}"; do
    TIME=$(echo "${PERCENTAGES[$i]} * $DURATION" | bc)
    TIMESTAMP=$(date -u -d @"$TIME" +%H:%M:%S)
    OUTPUT_FILE="${VIDEO_FILE}_thumb_${TIMESTAMP//:/}.png"
    FILES+=("$OUTPUT_FILE")
    ffmpeg -ss $TIME -i "$VIDEO_FILE" $SCALE -vframes 1 "$OUTPUT_FILE"
    # Add timestamp label to the thumbnail
    convert "$OUTPUT_FILE" -pointsize 20 -fill white -gravity South -annotate +0+5 "$TIMESTAMP" "$OUTPUT_FILE"
done

# Create a thumbnail sheet
montage "${FILES[@]}" -tile 4x2 -geometry +5+5 -border 10 -bordercolor black -background grey "${VIDEO_FILE}_thumbnail_sheet.png"

echo "Thumbnail sheet created: ${VIDEO_FILE}_thumbnail_sheet.png"

# Clean up the intermediary thumbnail files
rm "${FILES[@]}"
