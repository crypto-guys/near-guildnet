#!/bin/bash
# SCRIPT CONFIG
# This script was created by # Rickrods @ crypto-solutions.net for the NEAR Guildnet Network
# 

set -eu

# Get Ubuntu Version so we build the right one 
RELEASE=$(lsb_release -c -s)
# Change this to compile a different Version 
NEAR_VERSION="1.16.2"
# Change this to use a different repo
NEAR_REPO="https://github.com/solutions-crypto/nearcore.git"
vm_name="compiler"
 
############## 
# User Section 
# NOTE: You are not required to run the compile process it is options. 
# but the file /tmp/near/nearcore.tar is required for the install portion of the script
# The tar file contains 1 folder named binaries with all binaries inside of it 
#######################################################################################################

# Ensure the user has root privilages to execute the script
if [ "$USER" != "root" ]
then
echo " You must run this script with sudo privilage hint: "sudo ./install.sh" -->>EXITING>>>!!!"
exit
fi

echo "***  Do you want to compile the nearcore binaries?  y/n?  ***"
read -r NEAR_COMPILE

echo "***  Do you want to install the NEARD guildnet Service?  y/n?  ***"
read -r NEARD_INSTALL

if [ "$NEARD_INSTALL" == y ]
then
echo "***  Please input your validator-id  ***"
read -r VALIDATOR_ID
fi
 
echo "*** PLEASE NOTE: if you choose to enable the autoremove feature the tar file with the nearcore binaries will be moved to /usr/local/share upon script completion"
echo "***  Do you want to remove the install extra components and tmp files (LXD and /tmp/near) when finished? y/n?  ***"
read -r AUTO_REMOVE

#######################################################################################################
# This section has all funcitons the script will use they are ignored unless called upon 
#######################################################################################################

# Update and install required packages 
function update_via_apt
{
    echo "* Updating via APT and installing required packages"
    apt-get -qq update && apt-get -qq upgrade
    apt-get -qq install snapd squashfs-tools git curl python3
    sleep 5
    echo '* Install lxd using snap'
    snap install lxd

}

# Initializes the container software with preseed information. 
# NOTE: advanced init configs using "cloud-init" require cloud-tools and it is highly sugggested to use a cloud image
function init_lxd
{
echo "* Initializing LXD"
    cat <<EOF | lxd init --preseed
config: {}
networks:
- config:
    ipv4.address: auto
    ipv6.address: auto
  description: ""
  name: lxdbr1
  type: ""
  project: default
storage_pools:
- config: {}
  description: ""
  name: guildnet
  driver: dir
profiles:
- config: {}
  description: ""
  devices:
    eth0:
      name: eth0
      network: lxdbr1
      type: nic
    root:
      path: /
      pool: guildnet
      type: disk
  name: default
cluster: null
EOF

systemctl restart snapd
sleep 15
}

function launch_container
{
    echo "* Detected Ubuntu $RELEASE"
    echo "* Launching Ubuntu $RELEASE LXC container to build in"

    if [ "$RELEASE" == "focal" ]
    then
    lxc launch images:68d4b58311e0 ${vm_name}
    fi
    if [ "$RELEASE" == "bionic" ]
    then
    lxc launch images:88cd379f1e63 ${vm_name}
    fi

    echo "* Pausing for 15 seconds while the container initializes"
    sleep 15
    echo "* Install Required Packages"
    lxc exec ${vm_name} -- sh -c "apt-get -qq update"
    lxc exec ${vm_name} -- sh -c "apt-get -qq upgrade"
    lxc exec ${vm_name} -- sh -c "apt-get -qq autoremove"
    lxc exec ${vm_name} -- sh -c "apt-get -qq autoclean"
    lxc exec ${vm_name} -- sh -c "apt-get -y install git curl snapd squashfs-tools libclang-dev build-essential iperf llvm runc gcc g++ g++-multilib make cmake clang pkg-config libssl-dev libudev-dev libx32stdc++6-7-dbg lib32stdc++6-7-dbg python3-dev"
    lxc exec ${vm_name} -- sh -c "snap install rustup --classic"
    lxc exec ${vm_name} -- sh -c "rustup default nightly"
    lxc exec ${vm_name} -- sh -c "rustup update"
}

function compile_source
{
    echo "* Cloning the github source"
    lxc exec ${vm_name} -- sh -c "rm -rf /tmp/src && mkdir -p /tmp/src/ && git clone ${NEAR_REPO} /tmp/src/nearcore"
    echo "* Switching Version"
    lxc exec ${vm_name} -- sh -c "cd /tmp/src/nearcore && git checkout $NEAR_VERSION"
    echo "* Attempting to compile"
    lxc exec ${vm_name} -- sh -c "cd /tmp/src/nearcore && cargo build -p neard --release"
    lxc exec ${vm_name} -- sh -c "cd /tmp/src/nearcore && cargo build -p keypair-generator --release"
    lxc exec ${vm_name} -- sh -c "mkdir ~/binaries"
    lxc exec ${vm_name} -- sh -c "cd /tmp/src/nearcore/target/release/ && cp keypair-generator neard ~/binaries"
    lxc exec ${vm_name} -- sh -c "cd /tmp/src/nearcore/target/release/ && cp near ~/binaries/nearcore"
    lxc exec ${vm_name} -- sh -c "cd /tmp && tar -cf nearcore.tar -C ~/ binaries/"
}

# Create a tar file of the binaries and puts them in /tmp/near/nearcore.tar
function get_tarball
{
    echo "* Retriving the tarball and storing in /tmp/near/nearcore.tar"
    mkdir -p /usr/lib/near/guildnet
    mkdir -p /tmp/near
    lxc file pull ${vm_name}/tmp/nearcore.tar /tmp/near/nearcore.tar
}


# This function is the main function that installes the components required for compiling the source 
# It also compiles the code and exports the results in a tar file
function compile_nearcore 
{
    update_via_apt
    init_lxd
    launch_container
    compile_source
    get_tarball
    echo "***  The compile process has completed the binaries were stored in /tmp/near/nearcore.tar"
}

function create_user_and_group
{
    echo "* Guildnet Install Script Starting"
    echo "* Setting up required accounts, groups, and privilages"
    sudo groupadd near
    sudo adduser --system --disabled-login --disabled-password --ingroup near --no-create-home neard-guildnet
}

# Creating a system service that will run with the non privilaged service account neard-guildnet
function create_neard_service
{
    # Copy Guildnet Files to a suitable location
    sudo mkdir -p /usr/lib/near/guildnet
    wget https://raw.githubusercontent.com/crypto-guys/near-guildnet/main/nearcore/install/neard.service
    sudo cp neard.service /usr/lib/near/neard.service
    cd /tmp/near
    tar -xf nearcore.tar
    sudo cp -p /tmp/near/binaries/* /usr/local/bin

    echo '* Getting the correct files and fixing permissions'
    sudo neard --home /usr/lib/near/guildnet/ init --download-genesis --chain-id guildnet --account-id "$VALIDATOR_ID"
    sudo chown -R neard-guildnet:near -R /usr/lib/near

    echo '* Adding logfile conf for neard'
    sudo mkdir -p /usr/lib/systemd/journald.conf.d
    sudo wget https://raw.githubusercontent.com/crypto-guys/near-guildnet/main/nearcore/install/near.conf --output-file /usr/lib/systemd/journald.conf.d/neard.conf

    echo '* Service Status 'sudo systemctl status neard.service' *'
    sudo systemctl enable /usr/lib/near/neard.service
    sudo systemctl status neard.service
}

function clean_up 
{
    echo '* Would you like to delete the LXC container used to compile?   y/n?'
    read DELETE_CONT
    if [ "$DELETE_CONT" == "y" || "$DELETE_CONT" == "yes" ]
    then
    sudo lxc stop compiler
    sudo lxc delete compiler
    fi
    
    echo '* Would you like to uninstall LXD we installed it for the build container? '
    read DEL_LXD
    if [ "$DELETE_LXD" == "y" || "$DELETE_LXD" == "yes" ]
    then
    sudo snap remove lxd --purge
    fi
    echo '* To manually remove snapd ---   sudo apt purge snapd --autoremove'
    echo '* '
    echo '* Creating a backup copy of tarbarll in /usr/local/share'
    cp /tmp/near/nearcore.tar /usr/local/share
    rm -rf /tmp/near
}

# END Functions
#######################################################################################################


#######################################################################################################
# Use user supplied input to determine which parts of the script to run
if [ "$NEAR_COMPILE" == y ] || [ "$NEAR_COMPILE" == "yes" ]
then
compile_nearcore
fi

if [ "$NEARD_INSTALL" == "y" ] || [ "$NEARD_INSTALL" == "yes" ]
then
echo "* YOU MUST HAVE A TARFILE WITH THE BINARIES IN /tmp/near/nearcore.tar to install without running the compile first"
sleep 10
create_user_and_group
create_neard_service
fi

if [ "$AUTO_REMOVE" == "y" ] || [ "$AUTO_REMOVE" == "yes" ]
then
clean_up
fi

echo '* You should restart the machine now due to changes made to the logging system then check your validator key'
