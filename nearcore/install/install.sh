#!/bin/bash
set -eu
echo "* Starting the GUILDNET build process"

# Script settings 
RELEASE=$(lsb_release -c -s)
NEAR_VERSION=1.16.2-guildnet
NEAR_REPO="https://github.com/crypto-guys/nearcore.git"
vm_name="compiler"
NAME=$(echo $USER)

echo "* Updating via APT and installing required packages"
sudo apt-get -qq update && sudo apt-get -qq upgrade
sudo apt-get -qq install snapd squashfs-tools git curl python3
sleep 5

echo '* Install lxd using snap'
sudo snap install lxd

echo '* Pause 30 seconds'
sleep 30
sudo usermod -aG lxd $NAME

echo "* Initializing LXD"
    cat <<EOF | sudo lxd init --preseed
config:
  images.auto_update_interval: 15
storage_pools:
- config:
    size: 20GB
  description: ""
  name: default
  driver: zfs
networks:
- name: lxdbr0
  type: bridge
  config:
    ipv4.address: auto
    ipv6.address: none
profiles:
- config: {}
  description: ""
  devices:
    eth0:
      name: eth0
      network: lxdbr0
      type: nic
    root:
      path: /
      pool: default
      type: disk
  name: default
cluster: null

EOF

sudo systemctl restart snapd
sleep 15

echo "* Detected Ubuntu $RELEASE"
echo "* Launching Ubuntu $RELEASE LXC container to build in"
lxc launch ubuntu:$RELEASE ${vm_name}
echo "* Pausing for 90 seconds while the container initializes"
sleep 90

echo "* Install Required Packages"
lxc exec ${vm_name} -- /usr/bin/apt-get -qq update
lxc exec ${vm_name} -- /usr/bin/apt-get -qq upgrade
lxc exec ${vm_name} -- /usr/bin/apt-get -qq autoremove
lxc exec ${vm_name} -- /usr/bin/apt-get -qq autoclean
lxc exec ${vm_name} -- /usr/bin/apt-get -qq install git curl libclang-dev build-essential iperf llvm runc gcc g++ g++-multilib make cmake clang pkg-config libssl-dev libudev-dev libx32stdc++6-7-dbg lib32stdc++6-7-dbg python3-dev
lxc exec ${vm_name} -- /usr/bin/snap install rustup --classic
lxc exec ${vm_name} -- /snap/bin/rustup default nightly
lxc exec ${vm_name} -- /snap/bin/rustup update

echo "* Cloning the github source"
lxc exec ${vm_name} -- sh -c "rm -rf /tmp/src && mkdir -p /tmp/src/ && git clone $NEAR_REPO /tmp/src/nearcore"
echo "* Switching Version"
lxc exec ${vm_name} -- sh -c "cd /tmp/src/nearcore && git checkout 1.16.2-guildnet"
echo "* Attempting to compile"
lxc exec ${vm_name} -- sh -c "cd /tmp/src/nearcore && make release"
lxc exec ${vm_name} -- sh -c "mkdir ~/binaries"
lxc exec ${vm_name} -- sh -c "cd /tmp/src/nearcore/target/release/ && cp genesis-csv-to-json keypair-generator near-vm-runner-standalone neard state-viewer store-validator ~/binaries"
lxc exec ${vm_name} -- sh -c "cd /tmp/src/nearcore/target/release/ && cp near ~/binaries/nearcore"
lxc exec ${vm_name} -- sh -c "cd /tmp && tar -cf nearcore.tar -C ~/ binaries/"

echo "* Retriving the tarball and storing in ~/nearcore.tar"
sudo mkdir -p /usr/lib/near/guildnet
sudo mkdir -p /tmp/near
sudo lxc file pull ${vm_name}/tmp/nearcore.tar /tmp/near/nearcore.tar

echo "* Guildnet Install Script Starting"

echo " What is your validator accountId?"
read VALIDATOR_ID

# Script settings
CONFIG_URL="https://s3.us-east-2.amazonaws.com/build.openshards.io/nearcore-deploy/guildnet/config.json"
TARBALL="/tmp/near/nearcore.tar"

echo "* Setting up required accounts, groups, and privilages"
sudo groupadd near
sudo adduser --system --disabled-login --disabled-password --ingroup near --no-create-home neard-guildnet

# Set env variable is not really required unless you use the near-cli on same machine
# export NODE_ENV=guildnet

# Copy Guildnet Files to a suitable location
sudo mkdir -p /usr/lib/near/guildnet
cd /tmp/near
tar -xf nearcore.tar
sudo cp -p /tmp/near/binaries/* /usr/local/bin

echo '* Getting the correct files and fixing permissions'
sudo neard --home /usr/lib/near/guildnet/ init --download-genesis --chain-id guildnet --account-id $VALIDATOR_ID
sudo wget $CONFIG_URL -O /usr/lib/near/guildnet/config.json
sudo chown -R neard-guildnet:near -R /usr/lib/near

echo "* Creating systemd unit file for NEAR validator service"

sudo cat > /usr/lib/systemd/neard.service <<EOF
[Unit]
Description=NEAR GUILDNET Validator Service
Documentation=https://github.com/nearprotocol/nearcore
Wants=network-online.target
After=network-online.target

[Service]
Type=exec
User=neard-guildnet
Group=near
ExecStart=neard --home /usr/lib/near/guildnet/ run
Restart=on-failure
RestartSec=80
#StandardOutput=append:/var/log/guildnet.log

[Install]
WantedBy=multi-user.target
EOF

ln -s /usr/lib/systemd/neard.service /etc/systemd/system/neard.service

echo '* Adding logfile conf for neard'
sudo mkdir -p /usr/lib/systemd/journald.conf.d
sudo cat > /usr/lib/systemd/journald.conf.d/neard.conf <<EOF
#  This file is part of systemd
#
# This file controls the logging behavior of the service
# You can change settings by editing this file.
# Defaults can be restored by simply deleting this file.
#
# See journald.conf(5) for details.

[Journal]

Storage=auto
ForwardToSyslog=no
Compress=yes
#Seal=yes
#SplitMode=uid
SyncIntervalSec=1m
RateLimitInterval=30s
#RateLimitBurst=1000

EOF

echo '* Service Status 'sudo systemctl status neard.service' *'
sudo systemctl enable neard.service
sudo systemctl status neard.service

echo '* The installation has completed removing the installer'
lxc stop compiler
lxc delete compiler
rm -rf /tmp/near

echo '* You should now verify your validator key is correct'
cat /usr/lib/near/guildnet/validator_key.json | grep "account_id\|public_key"

echo '* You can verify this is correct using near-cli on another machine the staking key for the account_id should match'

echo "* near view <account_id>.guildnet get_staking_key '{}' "

echo "* Please restart the machine now then use these commands as needed | systemctl start/stop/enable/disable neard | journalctl -u neard | journalctl --help"
