
#Set the password timeout to 400 days

echo default-cache-ttl 34560000 > /home/$USER/.gnupg/gpg-agent.conf
echo max-cache-ttl 34560000 >> /home/$USER/.gnupg/gpg-agent.conf

sleep 1
gpgconf --kill gpg-agent
sleep 1
gpg-agent --daemon --use-standard-socket

