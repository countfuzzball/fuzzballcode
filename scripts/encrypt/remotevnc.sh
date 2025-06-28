#!/bin/bash
#connects to remove server and forwards the local port 5901 to port 4000 on the remote server
ssh -v -i /mnt/Local/GCloud/AL_privatekey.pem  -nNT -R 0.0.0.0:4000:localhost:5901 -p 22 andrewmcoughlan@35.207.189.194
