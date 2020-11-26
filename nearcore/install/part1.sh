#!/bin/bash
set -eu
echo "* Starting the GUILDNET builder"

# Script settings 
RELEASE=$(lsb_release -c -s)
NEAR_VERSION="1.16.2-guildnet"
NEAR_REPO="https://github.com/crypto-guys/nearcore.git"
ACCOUNT_ID=stakeu.staked.guildnet
CHAINID=guildnet
CONFIG_URL="https://s3.us-east-2.amazonaws.com/build.openshards.io/nearcore-deploy/guildnet/config.json"
vm_name="script-test"

echo "* Launching LXC container to build in"
lxc launch ubuntu:focal ${vm_name}
lxc exec script-compiler /bin/bash --force-noninteractive

echo "* Install Required Packages"
lxc exec ${vm_name} -- /usr/bin/apt-get -qq update
lxc exec ${vm_name} -- /usr/bin/apt-get -qq upgrade
lxc exec ${vm_name} -- /usr/bin/apt-get -qq autoremove
lxc exec ${vm_name} -- /usr/bin/apt-get -qq autoclean
lxc exec ${vm_name} -- /usr/bin/apt-get -qq install git curl libclang-dev build-essential iperf llvm runc gcc g++ g++-multilib make cmake clang pkg-config libssl-dev libudev-dev libx32stdc++6-7-dbg lib32stdc++6-7-dbg python3-dev
lxc exec ${vm_name} -- /usr/bin/snap install rustup --classic
lxc exec ${vm_name} -- /usr/bin/rustup default nightly
lxc exec ${vm_name} -- /usr/bin/rustup component add clippy-preview
lxc exec ${vm_name} -- /usr/bin/rustup update

# Compile Nearcore
lxc exec ${vm_name} -- /usr/bin/rm -rf /tmp/src
lxc exec ${vm_name} -- /usr/bin/mkdir -p /tmp/src/
lxc exec ${vm_name} -- /usr/bin/cd /tmp/src/ && git clone $NEAR_REPO
lxc exec ${vm_name} -- /usr/bin/cd nearcore
lxc exec ${vm_name} -- /usr/bin/git switch $NEAR_VERSION
lxc exec ${vm_name} -- /usr/bin/make release

echo '* nearcore is now compiled ***'
echo '* Not Finished Yet*
