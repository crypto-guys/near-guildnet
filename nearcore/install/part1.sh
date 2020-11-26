#!/bin/bash
set -eu
echo "* Starting the GUILDNET builder"

# Script settings 
RELEASE=$(lsb_release -c -s)
NEAR_VERSION="1.16.2-guildnet"
NEAR_REPO="https://github.com/crypto-guys/nearcore.git"
ACCOUNT_ID=<ENTER YOUR VALIDATOR ID>
CHAINID=guildnet
CONFIG_URL="https://s3.us-east-2.amazonaws.com/build.openshards.io/nearcore-deploy/guildnet/config.json"
# Timezone list is available using command "timedatectl list-timezones" use appropriate timezone
TIMEZONE=<FILL_THIS_IN>

echo "* Setting up the service account"
groupadd near
adduser --system --disabled-login --disabled-password --ingroup near --no-create-home guildnet
usermod -aG near guildnet

echo "* Fixing the time settings and locale"
timedatectl set-timezone $TIMEZONE
timedatectl set-ntp true
# This generates the locale for english US UTF-8 if yours is different change it
locale-gen en_US.UTF-8
mkdir -p /var/lib/near/home/guildnet

echo "* Install Required Packages"
# Prerequsits
apt-get -qq update
apt-get -qq upgrade
apt-get -qq autoremove
apt-get -qq autoclean
apt-get -qq install git curl libclang-dev build-essential iperf llvm runc gcc g++ g++-multilib make cmake clang pkg-config libssl-dev libudev-dev libx32stdc++6-7-dbg lib32stdc++6-7-dbg python3-dev
snap install rustup --classic
rustup default nightly
rustup component add clippy-preview
rustup update

# Compile Nearcore
rm -rf /tmp/src
mkdir -p /tmp/src/
cd /tmp/src/ && git clone $NEAR_REPO
cd nearcore
git switch $NEAR_VERSION
make release

echo '* nearcore is now compiled in /tmp/src/guildnet/target/release'
echo '* You should now run ./part2.sh'
