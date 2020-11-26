#!/bin/bash
set -eu
echo "* Guildnet Install Script Running"

# Script settings 
ACCOUNT_ID=<VALIDATOR_ACCOUT_ID_GOES_HERE>
CONFIG_URL=https://s3.us-east-2.amazonaws.com/build.openshards.io/nearcore-deploy/guildnet/config.json

# Set env variable
export NODE_ENV=guildnet

# Copy Guildnet Files to a suitable location
sudo mkdir -p /var/lib/near/home/guildnet
sudo chmod 664 /var/lib/near/home/guildnet/*
chmod 775 /var/lib/near
chmod 775 /var/lib/near/home
chmod 775 /var/lib/near/home/guildnet
chown -R guildnet_validator:near -R /var/lib/near
sudo cp -pr /tmp/src/guildnet/target/release/* /var/lib/near/home/guildnet

# Initialize Neard
cd /var/lib/near/home/guildnet
./neard --home /var/lib/near/home/guildnet init --download-genesis --account-id=$ACCOUNT_ID --chain-id=guildnet

echo '* Getting the correct files and fixing permissions'
wget $CONFIG_URL -O /var/lib/near-guildnet/home/config.json



echo "* Creating systemd unit file for NEAR validator service"
cat > /lib/systemd/system/near-guildnet-validator.service <<EOF
[Unit]
Description=NEAR GUILDNET Validator Service
Documentation=https://github.com/nearprotocol/nearcore
Wants=network-online.target
After=network-online.target

[Service]
User=guildnet_validator
Group=near
ExecStart=neard --home /var/lib/near/home/guildnet run
StandardOutput=file:/var/log/guildnet.log

[Install]
WantedBy=multi-user.target
EOF

ln -s /var/lib/near/home/guildnet/neard /usr/local/bin/neard
ln -s /lib/systemd/system/near-guildnet-validator.service /etc/systemd/system/multi-user.target.wants/near-guildnet-validator.service
chown -R guildnet_service:near /usr/local/bin/neard

echo '* Cleaning up the mess we made'
rm -rf /tmp/src/
sudo apt-get -qq purge --autoremove libclang-dev iperf llvm runc gcc g++ g++-multilib make cmake pkg-config libssl-dev libudev-dev libx32stdc++6-7-dbg lib32stdc++6-7-dbg python3-dev

echo '* The installation has completed successfully'
exit
