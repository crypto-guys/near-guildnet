## Description

- The compile script will run inside of LXC containers so you should have LXD/LXC installed.
- The compiler script will generate a tarball with the nearcore binaries to the users home folder that started the script
- The installer script requires the tarball to function. The installer can be run on most ubuntu 20.04 installations provided its with the tarball.
- We will create a systemd service that runs the compiled binaries with the non privilaged system account.

## Requirements

- Ubuntu 20.04 
- snapd
- lxd 
- **Both snapd and lxd are only installed to compile the software and are easily removed and cleaned from the system when complete**


    
## Instructions

- To install snapd
```sudo apt install snapd```

- To install lxd

```
sudo snap install lxd
sudo lxd init
```
You will be asked a series of questions these answers will word. Blank is default
```
Would you like to use LXD clustering? (yes/no) [default=no]: n
Do you want to configure a new storage pool? (yes/no) [default=yes]: yes
Name of the new storage pool [default=default]: 
Name of the storage backend to use (ceph, btrfs, dir, lvm, zfs) [default=zfs]: 
Create a new ZFS pool? (yes/no) [default=yes]: 
Would you like to use an existing empty block device (e.g. a disk or partition)? (yes/no) [default=no]: no
Size in GB of the new loop device (1GB minimum) [default=14GB]: 20
Would you like to connect to a MAAS server? (yes/no) [default=no]: no
Would you like to create a new local network bridge? (yes/no) [default=yes]: 
What should the new bridge be called? [default=lxdbr0]: 
What IPv4 address should be used? (CIDR subnet notation, “auto” or “none”) [default=auto]: 
What IPv6 address should be used? (CIDR subnet notation, “auto” or “none”) [default=auto]: 
Would you like LXD to be available over the network? (yes/no) [default=no]: 
Would you like stale cached images to be updated automatically? (yes/no) [default=yes] 
Would you like a YAML "lxd init" preseed to be printed? (yes/no) [default=no]:
```


- The install script will create the directories, user account, systemd service, and set the permissions for you.

#### Compile the source

- The compile script will generate a tarball that can be used to start the node in the users home directory
- The compile script should be run as root
```
sudo su
mkdir -p /tmp/guildnet && cd /tmp/guildnet
wget https://raw.githubusercontent.com/crypto-guys/near-guildnet/1.16.2-guildnet/nearcore/install/compiler 
chmod +x compiler
./compiler
```

#### Install the service

- The install script will create the directories, user account, systemd service, and set the permissions for you.

```
sudo su
cd /tmp/guildnet
wget https://raw.githubusercontent.com/crypto-guys/near-guildnet/1.16.2-guildnet/nearcore/install/installer
sudo chmod +x installer
./installer
```

#### To Remove leftover data and builder tools from installation
```
lxc stop compiler
lxc delete compiler
snap remove lxc
rm -rf /tmp/guildnet
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
