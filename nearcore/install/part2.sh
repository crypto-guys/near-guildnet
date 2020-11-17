#!/bin/bash
set -eu
echo "* Guildnet Install Script Running Part 2"

# Script settings 
ACCOUNT_ID=cryptosolutions.stake.guildnet
GENESIS_URL=https://s3.us-east-2.amazonaws.com/build.openshards.io/nearcore-deploy/guildnet/genesis.json
CONFIG_URL=https://s3.us-east-2.amazonaws.com/build.openshards.io/nearcore-deploy/guildnet/config.json


# Initialize Neard
cd /var/lib/near-guildnet
rm -rf /var/lib/near-guildnet/home/*
./neard --home /var/lib/near-guildnet/home init --account-id=$ACCOUNT_ID --chain-id=guildnet

# Get correct files
wget $GENESIS_URL -O /var/lib/near-guildnet/home/genesis.json
wget $CONFIG_URL -O /var/lib/near-guildnet/home/config.json
sudo chmod 664 /var/lib/near-guildnet/home/*
chmod 775 /var/lib/near-guildnet/home
chmod 775 /var/lib/near-guildnet/
chown -R guildnet_service:near -R /var/lib/near-guildnet
echo "* Creating systemd unit file for NEAR validator service"
cat > /lib/systemd/system/near-guildnet-validator.service <<EOF
[Unit]
Description=NEAR GUILDNET Validator Service
Documentation=https://github.com/nearprotocol/nearcore
Wants=network-online.target
After=network-online.target

[Service]
User=guildnet_service
Group=near
ExecStart=neard --home /var/lib/near-guildnet/home run
StandardOutput=file:/var/log/guildnet.log

[Install]
WantedBy=multi-user.target
EOF

ln -s /var/lib/near-guildnet/neard /usr/local/bin/neard
ln -s /lib/systemd/system/near-guildnet-validator.service /etc/systemd/system/multi-user.target.wants/near-guildnet-validator.service
chown -R guildnet_service:near /usr/local/bin/neard

exit
