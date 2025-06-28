#!/bin/bash

# Function to split an MP4 video into equal-length segments at keyframes
split_video() {
    local input_file="$1"
    local segment_length="$2"
    
    if [[ ! -f "$input_file" ]]; then
        echo "Error: Input file '$input_file' not found!"
        exit 1
    fi

    echo "Splitting '$input_file' into $segment_length-second segments at keyframes..."

    ffmpeg -i "$input_file" -c copy -map 0 -segment_time "$segment_length" \
        -force_key_frames "expr:gte(t,n_forced*$segment_length)" -f segment -reset_timestamps 1 "part_%03d.mp4"

    echo "Splitting complete. Checking segment integrity..."
    ffprobe part_000.mp4
}

# Function to merge MP4 segments back into a single file with metadata fixes
merge_videos() {
    local output_file="$1"

    if [[ -z "$output_file" ]]; then
        echo "Error: No output file specified."
        exit 1
    fi

    # Find all segment files
    segment_files=(part_*.mp4)
    
    if [[ ${#segment_files[@]} -eq 0 ]]; then
        echo "Error: No part_*.mp4 files found for merging!"
        exit 1
    fi

    # Create a list file for FFmpeg
    local file_list="file_list.txt"
    rm -f "$file_list"
    
    for file in "${segment_files[@]}"; do
        echo "file '$file'" >> "$file_list"
    done

    echo "Merging segments into '$output_file'..."
    
    ffmpeg -f concat -safe 0 -i "$file_list" -c copy -avoid_negative_ts make_zero "$output_file"

    echo "Fixing metadata..."
    MP4Box -inter 0 "$output_file"

    echo "Merging complete: '$output_file' created."
    
    # Clean up
    rm -f "$file_list"
}

# Main execution logic
if [[ "$1" == "split" ]]; then
    split_video "$2" "$3"
elif [[ "$1" == "merge" ]]; then
    merge_videos "$2"
else
    echo "Usage:"
    echo "  $0 split <input.mp4> <segment_length_in_seconds>"
    echo "  $0 merge <output.mp4>"
    exit 1
fi
