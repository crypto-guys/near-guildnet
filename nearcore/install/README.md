## Description

- Compiles nearcore-1.16.2-guildnet in an lxc container and exports a tar file with binaries
- Sets up the machine to run the binaries using systemd 
- Configures a new guildnet validator with config, genesis, and keys
- Options for logging
- TODO: Removes everything installed for the compile process

## Requirements

- Ubuntu 20.04 
    
## Instructions

- The install script will create the directories, user account, systemd service, and set the permissions for you.

```
mkdir -p /tmp/guildnet && cd /tmp/guildnet
wget https://raw.githubusercontent.com/crypto-guys/near-guildnet/guildnet-install/nearcore/install/install.sh
chmod +x install.sh
sudo ./install.sh
```

The installer script has an option to enter the validator name so the validator key is generated correctly


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

- View logs available
    ```journalctl -u neard-guildnet -x```
    ```journalctl --help"

