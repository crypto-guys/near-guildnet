#!/bin/bash
set -eu
echo "* Guildnet Install Script Running}"


# Script settings 
RELEASE=$(lsb_release -c -s)
NEAR_VERSION="tags/1.16.0-rc.3"
NEAR_REPO="https://github.com/near/nearcore.git"
ACCOUNT_ID=<ENTER YOUR VALIDATOR ID>
CHAINID=guildnet
GENESIS_URL="https://s3.us-east-2.amazonaws.com/build.openshards.io/nearcore-deploy/guildnet/genesis.json"
CONFIG_URL="https://s3.us-east-2.amazonaws.com/build.openshards.io/nearcore-deploy/guildnet/config.json"



echo "* Setting up the service account"
sudo groupadd near
sudo adduser --system --disabled-login --disabled-password --ingroup near --no-create-home guildnet_service
sudo usermod -aG syslog guildnet_service
sudo usermod -aG near $USER

echo "* Fixing the time settings and locale"

sudo timedatectl set-timezone America/Chicago
sudo timedatectl set-ntp true
sudo locale-gen en_US.UTF-8
sudo mkdir -p /var/lib/near-guildnet
sudo mkdir -p /var/lib/near-guildnet/home

echo "* Install APT Packages"
# Prerequsits
sudo apt-get -qq update
sudo apt-get -qq upgrade
sudo apt-get -qq autoremove
sudo apt-get -qq autoclean
sudo apt-get -qq install git curl libclang-dev build-essential iperf llvm runc gcc g++ g++-multilib make cmake clang pkg-config libssl-dev libudev-dev libx32stdc++6-7-dbg lib32stdc++6-7-dbg python3-dev


#################################################################################
##
##          Install Rust
##
#################################################################################
echo '* Installing rust now'
rm -rf /tmp/src/
mkdir -p /tmp/src/rustup/
cd /tmp/src/rustup/
wget https://static.rust-lang.org/rustup/dist/x86_64-unknown-linux-gnu/rustup-init
sudo chmod +x rustup-init
./rustup-init --quiet -y --default-toolchain nightly
source /home/$USER/.cargo/env
rustup update
rustup component add clippy-preview
rustup default nightly


# Compile Nearcore
git clone $NEAR_REPO /tmp/src/guildnet
cd /tmp/src/guildnet
git checkout $NEAR_VERSION
make release

# Set env variable
export NODE_ENV=guildnet

# Copy Guildnet Files
sudo cp -pr /tmp/src/guildnet/target/release/* /var/lib/near-guildnet
