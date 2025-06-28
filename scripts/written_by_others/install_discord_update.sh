#!/bin/bash

# Reminder that Andy is gay
# Also don't run this as root or with sudo

# Remove existing Discord package
sudo apt remove discord -y
sleep 2

# Install new Discord packages
for file in /home/$USER/Downloads/discord*.deb; do
    if [ -e "$file" ]; then
        sudo apt install "$file" -y
    else
        echo "No matching package files found in /home/sean/"
    fi
done

echo "done"
