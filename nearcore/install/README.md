## Description

- Compiles nearcore-1.16.2 for guildnet in an lxc container and exports a tar file with binaries
- Sets up the machine to run the binaries using systemd 
- Configures a new guildnet validator with config, genesis, and keys
- Options for logging
- Removes everything installed for the compile process

## Requirements

- Ubuntu (**20.04 focal** or **18.04 bionic**)
    
## Instructions

- The install script will create the directories, user account, systemd service, and set the permissions for you. Ubuntu should be set up and you should run the script with the user you will be managing the node with.
- **Please NOTE**: This script is configured to compile a specific version of nearcore for the guildnet network. However by changing the github repo and version variables you can compile any nearcore version for any network in a LXC container that deletes itself when finished.

```
wget https://raw.githubusercontent.com/crypto-guys/near-guildnet/main/nearcore/install/install.sh
chmod +x install.sh
sudo ./install.sh
```

The installer script has an option to enter the validator name so the validator key is generated correctly

## Use

### Using the install script

- This script can be used to compile any version of nearcore from any repo you specify see lines 5-8 of install.sh
- If you want to just compile the source code and get a tarball look in the install.sh code comments

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
    ```sudo journalctl -x -u neard-guildnet ```
    
    ```journalctl --help```

