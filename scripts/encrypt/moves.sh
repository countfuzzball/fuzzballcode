#!/bin/bash

# Ensure a directory argument is provided
if [ -z "$1" ]; then
    echo "Usage: $0 <directory>"
    exit 1
fi

dir="$1"
current_dir=$(pwd)

declare -A file_map

# Find all files recursively
while IFS= read -r -d '' file; do
    filename=$(basename -- "$file")
    
    if [[ -e "$current_dir/$filename" ]]; then
        echo "Warning: Duplicate file '$filename' found. Skipping move."
    else
        file_map["$filename"]="$file"
    fi
done < <(find "$dir" -type f -print0)

# Move non-duplicate files
for filename in "${!file_map[@]}"; do
    mv "${file_map[$filename]}" "$current_dir/"
    echo "Moved: $filename"
done
