#!/bin/bash

# Ensure a filename is passed as an argument
if [[ $# -eq 0 ]]; then
    echo "Usage: $0 <filename>"
    exit 1
fi

FILENAME="$1"

# Check if file exists
if [[ ! -f "$FILENAME" ]]; then
    echo "Error: File '$FILENAME' does not exist."
    exit 1
fi

FILENAME_LEN=$(printf "%04d" ${#FILENAME})  # Format the length to exactly 4 characters (e.g., "0015" for 15)

# Send the header, filename length, filename, and the image binary data
(
    echo -ne "IMG "            # Send the header (must be exactly 4 bytes, including the space)
    echo -ne "$FILENAME_LEN"    # Send the filename length, as 4 bytes (e.g., "0015")
    echo -ne "$FILENAME"        # Send the filename itself
    cat "$FILENAME"             # Send the binary content of the file
) | nc -N -w 1 localhost 12346      # Use -w 1 to set a 1-second timeout after EOF, ensuring the connection is properly closed
