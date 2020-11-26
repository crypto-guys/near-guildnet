## Description

- These scripts run inside of LXC containers so you should have LXD/LXC installed.
- The compiler script will generate a tarball with the nearcore binaries to the users home folder that started the script
- The installer script requires the tarball to function. They can be run on most ubuntu 20.04 installations.
- We create a system account and system service that runs with the non privilaged system account.
- More scripts are available to install optional monitoring tools and their dependencies if needed

## Requirements

- Ubuntu 20.04 
- snap
- lxd / lxc

    
## Instructions

- The compile script will generate a tarball that can be used to start the node
- The install script will create the directories, user account, systemd service, and set the permissions for you.
- NOTE: The install script will initialize a new validator in the folder /var/lib/near/guildnet if it does not already exist

#### Compile the source

```
mkdir -p /tmp/guildnet && cd /tmp/guildnet
wget https://raw.githubusercontent.com/crypto-guys/near-guildnet/1.16.2-guildnet/nearcore/install/compiler > compiler.sh
sudo chmod +x compiler.sh
./compiler.sh
```

#### Install the service

```
cd /tmp/guildnet
wget https://raw.githubusercontent.com/crypto-guys/near-guildnet/1.16.2-guildnet/nearcore/install/installer > install.sh
sudo chmod +x install.sh
./install.sh
```

## Use

#### Enabling the service on boot
- ```sudo systemctl enable neard-guildnet.service```

#### Starting the service 
- ```sudo systemctl start neard-guildnet.service```

#### Stopping the service 
- ```sudo systemctl stop neard-guildnet.service```

#### Check service status
- ```sudo systemctl status near-guildnet.service```

#### Logging

- ```tail /var/log/guildnet.log --follow```
- ```cat /var/log/guildnet.log```
- ```sudo journalctl -u neard-guildnet.service -x```
