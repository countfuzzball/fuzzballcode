#Uses lsof to find what services/connections are running on a particular port.
#Useful for finding dangling ssh connections when a reverse ssh tunnel is active.

sudo lsof -i TCP:2222
