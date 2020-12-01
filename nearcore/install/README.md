## Description

- Compiles nearcore-1.16.2-guildnet in an lxc container and exports a tar file with binaries
- Sets up the machine to run the binaries using systemd 
- Configures a new guildnet validator with config, genesis, and keys
- Options for logging
- Removes everything installed for the compile process

## Requirements

- Ubuntu 20.04 
- snapd
- lxd 
- **Both snapd and lxd are only installed to compile the software and are easily removed and cleaned from the system when complete**


    
## Instructions

- To install snapd
```sudo apt install snapd```

- The install script will create the directories, user account, systemd service, and set the permissions for you.

#### Compile the source

- The compile script will generate a tarball that can be used to start the node in the users home directory
- The compile script should be run as root
```
sudo su
```
usermod -aG lxd **/your current username/**
```
mkdir -p /tmp/guildnet && cd /tmp/guildnet
wget https://raw.githubusercontent.com/crypto-guys/near-guildnet/1.16.2-guildnet/nearcore/install/compiler 
chmod +x compiler
./compiler
```

#### Install the service

- The install script will create the directories, user account, systemd service, and set the permissions for you.
- It will create a folder in /var/lib/near to store the validator home folder the correct genesis and config files will be there
```
sudo su
cd /tmp/guildnet
wget https://raw.githubusercontent.com/crypto-guys/near-guildnet/1.16.2-guildnet/nearcore/install/installer
```
The installer script has an option to enter the validator name so your validator key is generated correctly
```
sudo nano installer
enter your validator id in the location provided near the top
save and exit
```
```
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

**By default all logging information is sent to the journal. For more information see journalctl --help**

If you prefer logs to go to a file uncomment the noted line in the neard-guildnet unit file.

- Quick check to see the validators most recent status
    ```sudo systemctl status near-guildnet.service```

- View all logs available
    ```journalctl -u neard-guildnet -x```

