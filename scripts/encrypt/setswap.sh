# Set the swappiness to 100
# This makes the system more aggressive in swapping out pages to the swap space.
sudo sh -c 'echo 100 > /proc/sys/vm/swappiness'
echo "Set swappiness to 100"

# Set overcommit_memory to 2
# This setting makes the kernel strict about memory allocation, preventing overcommitting.
#sudo sh -c 'echo 2 > /proc/sys/vm/overcommit_memory'
echo "Set overcommit_memory to 2"

# Set min_free_kbytes to 200MB
# This ensures the system keeps at least 200MB of RAM free at all times to prevent OOM situations.
#sudo sh -c 'echo 204800 > /proc/sys/vm/min_free_kbytes'
echo "Set min_free_kbytes to 204800 (200MB)"

echo "Virtual memory parameters have been set."
