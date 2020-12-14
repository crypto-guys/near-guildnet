#!/bin/bash

# This script will remove everything the install script installs. 
# It will allow install.sh to be run again and again on the same machine if needed

sudo snap remove lxd --purge
sudo userdel neard-guildnet
sudo groupdel near
sudo rm -rf /usr/lib/near/guildnet
sudo systemctl stop neard
sudo systemctl disable neard
sudo rm /usr/local/bin/neard
