#!/bin/bash

# Find the mounted directory starting with "b.crypt."
output_dir=$(mount | grep -o '/[^ ]*tek\.img.crypt\.[0-9]*' | head -n 1)

# Check if the output directory is found
if [ -z "$output_dir" ]; then
    echo "Error: No mounted directory starting with 'b.crypt.' found."
    exit 1
fi

today=$(date +%F)

mkdir $output_dir
# Loop through all .gpg files in the current directory
for file in *.gpg; do


    if [ -f "$file" ]; then
	full_dir_path="${output_dir}/${today}"
	mkdir -p "$full_dir_path"


        # Construct the output file name
        output_file="${full_dir_path}/${file%.gpg}.tar"

        # Decrypt the file and save as a tar file
        gpg --output "$output_file" --decrypt "$file"
        
        echo "Decrypted $file to $output_file"
    fi
done
