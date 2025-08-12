#!/bin/bash

# Check if the correct number of arguments are provided
if [ "$#" -ne 3 ]; then
    echo "Usage: $0 <source_directory> <destination_directory> <folder_prefix>"
    exit 1
fi

SOURCE_DIR="$1"
DEST_DIR="$2"
FOLDER_PREFIX="$3"

# Create the destination directory if it doesn't exist
mkdir -p "$DEST_DIR"

# Initialize variables
current_folder_number=1
current_folder_size=0
max_size=734003200 # 700MB in bytes
current_dest_folder="$DEST_DIR/${FOLDER_PREFIX}_$current_folder_number"
mkdir -p "$current_dest_folder"
large_folder_number=1

# Function to copy directory contents
copy_directory() {
    local src_dir=$1
    local dest_dir=$2
    rsync -a --progress "$src_dir" "$dest_dir"
}

# Function to copy large directories
copy_large_directory() {
    local src_dir=$1
    local large_dest_folder="$DEST_DIR/${FOLDER_PREFIX}_large_$large_folder_number"
    mkdir -p "$large_dest_folder"
    rsync -a --progress "$src_dir" "$large_dest_folder"
    echo "Copied $src_dir to $large_dest_folder for manual sorting."
    large_folder_number=$((large_folder_number + 1))
}

# Loop through each item in the source directory
for item in "$SOURCE_DIR"/*; do
    if [ -e "$item" ]; then  # Check if item exists
        item_size=$(du -sb "$item" | cut -f1)

        if [ $item_size -gt $max_size ]; then
            # Move to a separate large folder if the item itself is too large
            copy_large_directory "$item"
        else
            if [ $((current_folder_size + item_size)) -gt $max_size ]; then
                # Increment the folder number and reset size
                current_folder_number=$((current_folder_number + 1))
                current_dest_folder="$DEST_DIR/${FOLDER_PREFIX}_$current_folder_number"
                mkdir -p "$current_dest_folder"
                current_folder_size=0
            fi

            # Copy the directory or file
            copy_directory "$item" "$current_dest_folder"

            # Update the current folder size
            current_folder_size=$((current_folder_size + item_size))
        fi
    fi
done

echo "Copying completed."
