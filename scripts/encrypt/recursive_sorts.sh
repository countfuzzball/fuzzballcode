#!/bin/bash

SRC_DIR="$1"   # Source directory to back up (e.g., where 'set1', 'set2', etc. are located)
DEST_DIR="$2"   # Destination directory where chunks will be stored
PREFIX="AL"   # Prefix for the chunk directories
CHUNK_SIZE_MB=700  # Size of each chunk in MB
TEMP_DIR="/mnt/tmp/sfl"   # Fixed temporary directory to manage files for chunking
CHUNK_SUFFIX="c"  # Suffix for the chunk directories

# Function to get the size of a directory in MB
get_dir_size_mb() {
    local dir=$1
    du -sm "$dir" | awk '{print $1}'
}

# Ensure both source and destination directories are provided
if [ -z "$SRC_DIR" ] || [ -z "$DEST_DIR" ]; then
    echo "Error: Source and destination directories must be provided."
    echo "Usage: $0 <source_directory> <destination_directory>"
    exit 1
fi

# Ensure source directory exists
if [ ! -d "$SRC_DIR" ]; then
    echo "Error: Source directory '$SRC_DIR' does not exist."
    exit 1
fi

# Ensure destination directory exists or create it
if [ ! -d "$DEST_DIR" ]; then
    mkdir -p "$DEST_DIR" || {
        echo "Error: Failed to create destination directory '$DEST_DIR'."
        exit 1
    }
fi

# Create the fixed temporary directory
mkdir -p "$TEMP_DIR"

# Loop through the top-level directories in the source
for top_dir in "$SRC_DIR"/*; do
    if [ -d "$top_dir" ]; then
        top_dir_name=$(basename "$top_dir")
        current_chunk=1
        
           # Create initial chunk directory
        chunk_dir="$DEST_DIR/${PREFIX}_${top_dir_name}_${CHUNK_SUFFIX}_${current_chunk}"
        mkdir -p "$chunk_dir"

        # Find all files in the top-level directory
        find "$top_dir" -type f | while read -r file; do
            file_size=$(du -sm "$file" | awk '{print $1}')

            # Handle large files exceeding chunk size by placing them in their own chunk
            if (( file_size > CHUNK_SIZE_MB )); then
                current_chunk=$((current_chunk + 1))
                large_file_chunk_dir="$DEST_DIR/${PREFIX}_${top_dir_name}_${CHUNK_SUFFIX}_${current_chunk}"
                mkdir -p "$large_file_chunk_dir"
                
                # Copy the large file to its own chunk directory
                rsync -a "$file" "$large_file_chunk_dir/"
                continue
            fi

            chunk_dir_size=$(get_dir_size_mb "$chunk_dir")

            # If adding the current file exceeds the chunk size, create a new chunk
            if (( chunk_dir_size + file_size > CHUNK_SIZE_MB )); then
                current_chunk=$((current_chunk + 1))
                chunk_dir="$DEST_DIR/${PREFIX}_${top_dir_name}_${CHUNK_SUFFIX}_${current_chunk}"
                mkdir -p "$chunk_dir"
            fi

            # Calculate target directory within the chunk without including top-level directory
            relative_path="${file#$top_dir/}"
            target_dir="$chunk_dir/$(dirname "$relative_path")"
            mkdir -p "$target_dir"

            # Copy the file to the target directory
            rsync -a "$file" "$target_dir/"
        done
    fi

done

# Clean up
test -d "$TEMP_DIR" && rm -rf "$TEMP_DIR"

echo "Backup completed successfully."

#Version 1.2 IMPROVED CHUNK SIZE MANAGEMENT!
