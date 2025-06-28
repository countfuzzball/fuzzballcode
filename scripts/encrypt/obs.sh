#!/bin/bash

# Define directories
obfuscated_dir="obf"
mapping_dir="mp"

# Create directories if they don't exist
mkdir -p "$obfuscated_dir"
mkdir -p "$mapping_dir"

# Process each item in the current directory
for item in *; do
    if [[ -e "$item" && "$item" != "$obfuscated_dir" && "$item" != "$mapping_dir" ]]; then
        # Generate an 8-character hash from the item's name
        hash=$(echo -n "$item" | sha256sum | awk '{print substr($1, 1, 8)}')

        # Generate 4 random alphanumeric characters
        rand=$(tr -dc 'a-zA-Z0-9' </dev/urandom | head -c 4)

        # Create the new obfuscated name
        newname="${hash}${rand}.tar"

        # Save the mapping
        echo "$item -> $newname" >> "$mapping_dir/fm"

        # Archive the item into the obfuscated directory
        tar -cf "$obfuscated_dir/$newname" --exclude="$obfuscated_dir/$newname" "$item"

        # Remove the original item after archiving
        rm -rf "$item"
    fi
done

echo "Obfuscation complete! Mapping stored in $mapping_dir/filename_mapping.txt"
