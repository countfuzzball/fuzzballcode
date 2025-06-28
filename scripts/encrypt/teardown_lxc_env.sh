#!/bin/bash

# Set variables
SCRATCHFILE="/mnt/zTV/scratchfile.img"
MOUNTPOINT="/mnt/zTV/scratchspace"

# Unmount the loopback file
echo "Unmounting the loopback file..."
umount "$MOUNTPOINT"

# Remove the symlink
if [ -L /var/lib/lxc ]; then
    echo "Removing symlink /var/lib/lxc..."
    rm /var/lib/lxc
fi

# Remove the mount point directory
if [ -d "$MOUNTPOINT" ]; then
    echo "Removing mount point directory..."
    rmdir "$MOUNTPOINT"
fi

# Optional: Remove entry from /etc/fstab if it exists
echo "Would you like to remove the entry from /etc/fstab? (yes/no)"
read REMOVE_FSTAB

if [ "$REMOVE_FSTAB" == "yes" ]; then
    sed -i "\|$SCRATCHFILE|d" /etc/fstab
    echo "Entry removed from /etc/fstab."
fi

echo "Teardown complete."
