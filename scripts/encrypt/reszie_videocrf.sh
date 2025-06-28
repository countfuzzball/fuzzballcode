#!/bin/bash

# Usage: ./shrink_video.sh input.mp4 target_size_MB output.mp4

if [ "$#" -ne 3 ]; then
    echo "Usage: $0 input.mp4 target_size_MB output.mp4"
    exit 1
fi

input_file="$1"
target_size_MB="$2"
output_file="$3"

# Get video duration in seconds
duration=$(ffmpeg -i "$input_file" 2>&1 | awk -F: '/Duration/ {print int(($2 * 3600) + ($3 * 60) + $4)}' | head -n 1)

# Set CRF dynamically based on target size
if [ "$target_size_MB" -lt 10 ]; then
    crf=37   # Very compressed (small files)
elif [ "$target_size_MB" -lt 20 ]; then
    crf=35   # Small but watchable
elif [ "$target_size_MB" -lt 50 ]; then
    crf=33   # Medium compression
else
    crf=30   # Higher quality
fi

# Get original resolution and frame rate
original_resolution=$(ffmpeg -i "$input_file" 2>&1 | awk -F'[ ,]+' '/Stream.*Video/ {print $5}' | head -n 1)
original_fps=$(ffmpeg -i "$input_file" 2>&1 | awk -F'[ ,]+' '/Stream.*Video/ {for(i=1;i<=NF;i++) if($i ~ /fps/) print $(i-1); exit}')

# Reduce resolution if needed
scaled_resolution="640:-2"  # Maintain aspect ratio, reduce width to 640px

if [ "$target_size_MB" -lt 50 ]; then
    scaled_resolution="480:-2"   # Drop to 480p
elif [ "$target_size_MB" -lt 20 ]; then
    scaled_resolution="320:-2"   # Drop to 320p
fi

# Reduce frame rate if needed
scaled_fps=24  # Default to 24fps

if [ "$target_size_MB" -lt 20 ]; then
    scaled_fps=15
elif [ "$target_size_MB" -lt 10 ]; then
    scaled_fps=10
fi

echo "Encoding with CRF: $crf"
echo "Scaling resolution to: $scaled_resolution, Frame rate: $scaled_fps fps"

# Re-encode video with CRF instead of fixed bitrate
ffmpeg -i "$input_file" -c:v libx264 -crf "$crf" -preset slow -vf "scale=$scaled_resolution,fps=$scaled_fps" -c:a aac -b:a 64k "$output_file"

echo "Encoding complete: $output_file"
