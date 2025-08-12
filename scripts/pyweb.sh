#!/bin/bash
if pgrep -fx "python -m SimpleHTTPServer 80"; then 

echo "Web server is up"; 

else

cd /mnt/Remote/Apache/www/
python -m SimpleHTTPServer 80

fi
