#!/bin/bash

# Set variables
SCRATCHFILE="/mnt/zTV/scratchfile.img"
MOUNTPOINT="/mnt//zTV/scratchspace"
SIZE="10240" # Size in MB (10GB)

# Create a loopback file if it doesn't exist
if [ ! -f "$SCRATCHFILE" ]; then
    echo "Creating a loopback file..."
    # This will create a 10GB file
    dd if=/dev/zero of="$SCRATCHFILE" bs=1M count=$SIZE

    # Format the loopback file
    echo "Formatting the loopback file..."
    mkfs.ext4 "$SCRATCHFILE"
else
    echo "Loopback file already exists."
fi

# Create mount point directory if it doesn't exist
if [ ! -d "$MOUNTPOINT" ]; then
    echo "Creating mount point directory..."
    mkdir -p "$MOUNTPOINT"
fi

# Mount the loopback file
echo "Mounting the loopback file..."
mount -o loop "$SCRATCHFILE" "$MOUNTPOINT"

# Remove existing /var/lib/lxc if it exists and is a directory
if [ -d "/var/lib/lxc" ]; then
    echo "Removing existing /var/lib/lxc directory..."
    rm -rf /var/lib/lxc
fi

# Create symlink from /var/lib/lxc to the mount point
echo "Creating symlink from /var/lib/lxc to the mount point..."
ln -s "$MOUNTPOINT" /var/lib/lxc

# Verify the mount
echo "Verifying the mount..."
df -h | grep "$MOUNTPOINT"

# Print success message
echo "Setup complete. The loopback file is mounted and symlinked to /var/lib/lxc."

# Optional: Add entry to /etc/fstab to automount on boot
echo "Would you like to add an entry to /etc/fstab to automount on boot? (yes/no)"
read ADD_FSTAB

if [ "$ADD_FSTAB" == "yes" ]; then
    echo "$SCRATCHFILE $MOUNTPOINT ext4 loop 0 0" >> /etc/fstab
    echo "Entry added to /etc/fstab."
fi

echo "Done."
