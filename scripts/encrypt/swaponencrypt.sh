#!/bin/bash

# Check if the swapfile argument is provided
if [ -z "$1" ]; then
    echo "Usage: $0 <swapfile>"
    exit 1
fi

SWAPFILE=$1

# Set up the encrypted swap
sudo cryptsetup open --type plain --key-file /dev/urandom "$SWAPFILE" cryptswap

# Format the encrypted swap
sudo mkswap /dev/mapper/cryptswap

# Enable the swap
sudo swapon /dev/mapper/cryptswap

echo "Encrypted swap has been set up and activated for $SWAPFILE."
