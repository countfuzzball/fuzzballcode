#!/bin/bash

# Exit on error
set -e

# Usage check
if [[ -z "$1" ]]; then
    echo "Usage: $0 <image_name> [file_size] [key_file]"
    exit 1
fi

# Parameters
imagename=$1
filesize=${2:-3760M}
keyfile=${3:-/tmp/keyfile}

# Find available loop device
nextloopdevice=$(losetup --find)

# Allocate file
sudo truncate -s "$filesize" "$imagename" || { echo "Failed to allocate file"; exit 1; }
#sudo fallocate -l "$filesize" "$imagename" || { echo "Failed to allocate file"; exit 1; }

# Setup encryption
sudo cryptsetup -h sha512 -s 512 -i 8000 --use-urandom -y luksFormat "$imagename" --key-file="$keyfile"

# Setup loop device
sudo losetup "$nextloopdevice" "$imagename"
sudo cryptsetup open --key-file="$keyfile" "$nextloopdevice" "$imagename"

# Create filesystem
sudo mkfs.ext4 -M 0 /dev/mapper/"$imagename"

# Cleanup
trap 'sleep 30; sudo cryptsetup close "$imagename"; sleep 30; sudo losetup --detach "$nextloopdevice"' EXIT

echo "Setup completed successfully."
