#!/bin/bash
set -eu
echo "* Starting the GUILDNET build process"

# Script settings 
RELEASE=$(lsb_release -c -s)
NEAR_VERSION=1.16.2-guildnet
NEAR_REPO="https://github.com/crypto-guys/nearcore.git"
vm_name="compiler"

sudo snap install lxd
sudo usermod -aG lxd $USER

# echo "* Initializing LXD"
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

sudo snap restart lxd
sleep 2

echo "* Launching LXC container to build in"
lxc launch ubuntu:focal ${vm_name}
echo "* Pausing for 60 seconds while the container initializes"
sleep 60

echo "* Install Required Packages"
lxc exec ${vm_name} -- /usr/bin/apt-get -qq update
lxc exec ${vm_name} -- /usr/bin/apt-get -qq upgrade
lxc exec ${vm_name} -- /usr/bin/apt-get -qq autoremove
lxc exec ${vm_name} -- /usr/bin/apt-get -qq autoclean
lxc exec ${vm_name} -- /usr/bin/apt-get -qq install git curl libclang-dev build-essential iperf llvm runc gcc g++ g++-multilib make cmake clang pkg-config libssl-dev libudev-dev libx32stdc++6-7-dbg lib32stdc++6-7-dbg python3-dev
lxc exec ${vm_name} -- /usr/bin/snap install rustup --classic
lxc exec ${vm_name} -- /snap/bin/rustup default nightly
# lxc exec ${vm_name} -- /snap/bin/rustup component add clippy-preview
lxc exec ${vm_name} -- /snap/bin/rustup update

echo "* Cloning the github source"
lxc exec ${vm_name} -- sh -c "rm -rf /tmp/src && mkdir -p /tmp/src/ && git clone $NEAR_REPO /tmp/src/nearcore"
echo "* Switching Version"
lxc exec ${vm_name} -- sh -c "cd /tmp/src/nearcore && git switch 1.16.2-guildnet"
echo "* Attempting to compile"
lxc exec ${vm_name} -- sh -c "cd /tmp/src/nearcore && make release"

echo "* Creating tarball"
lxc exec ${vm_name} -- sh -c "mkdir -p /binaries/compressed && cd /tmp/src/nearcore/target/release/ && cp -p genesis-csv-to-json keypair-generator near near-vm-runner-standalone neard state-viewer store-validator /binaries"
lxc exec ${vm_name} -- sh -c "cd /binaries/compressed && tar -cvf nearcore1.16.2-guildnet.tar -C / binaries"

echo "* Retriving the tarball and storing in /src/nearcore-guildnet"
mkdir -p nearcore-guildnet
lxc file pull ${vm_name}/binaries/compressed/nearcore1.16.2-guildnet.tar nearcore-guildnet/nearcore-guildnet.tar
ls nearcore-guildnet/

echo "* Guildnet Install Script Starting"

echo " What is your validator accountId?"
read VALIDATOR_ID

# Script settings
CONFIG_URL="https://s3.us-east-2.amazonaws.com/build.openshards.io/nearcore-deploy/guildnet/config.json"
TARBALL="nearcore-guildnet/nearcore-guildnet.tar"

echo "* Setting up required accounts, groups, and privilages"
sudo groupadd near
sudo adduser --system --disabled-login --disabled-password --ingroup near --no-create-home neard-guildnet

# Set env variable is not really required unless you use the near-cli on same machine
# export NODE_ENV=guildnet

# Copy Guildnet Files to a suitable location
sudo mkdir -p /var/lib/near/guildnet
tar -xf $TARBALL
cd binaries
# Remove the extra folder
rm -rf compressed/
sudo cp * /usr/local/bin

echo '* Getting the correct files and fixing permissions'
sudo neard --home /var/lib/near/guildnet/ init --download-genesis --chain-id guildnet --account-id $VALIDATOR_ID
sudo wget $CONFIG_URL -O /var/lib/near/guildnet/config.json
sudo chown -R neard-guildnet:near -R /var/lib/near

echo "* Creating systemd unit file for NEAR validator service"

sudo cat > /var/lib/systemd/neard-guildnet.service <<EOF
[Unit]
Description=NEAR GUILDNET Validator Service
Documentation=https://github.com/nearprotocol/nearcore
Wants=network-online.target
After=network-online.target

[Service]
Type=exec
User=neard-guildnet
Group=near
ExecStart=neard --home /var/lib/near/guildnet/ run
Restart=on-failure
RestartSec=45
#StandardOutput=append:/var/log/guildnet.log

[Install]
WantedBy=multi-user.target

EOF

sudo ln -s /var/lib/systemd/neard-guildnet.service /etc/systemd/system
#sudo systemctl enable neard-guildnet.service
#sudo systemctl status neard-guildnet.service

echo '* The installation has completed removing the installer'
lxc stop compiler
lxc delete compiler
sudo snap remove --purge lxd
rm -rf /tmp/guildnet
