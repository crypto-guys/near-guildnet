## Description

- Compiles nearcore-1.16.2 for guildnet 
- Creates a lxc container to compile the binaries and exports a tar file with binaries back to the host
- Sets up the host machine to run the binaries using systemd 
- Creates a neard system service that runs with a non-privilaged system account
- Configures a new guildnet validator with config, genesis, and keys
- Options for logging
- Removes everything installed for the compile process if requested

This script could be used in many ways have fun!!!

## Requirements

- Ubuntu (**20.04 focal** or **18.04 bionic**)
- sudo access
    
## Instructions

- The install script will create the directories, user account, systemd service, and set the permissions for you. 
- Ubuntu should be set up and you should run the script using sudo from your users account.
- The script has 3 steps. 
    1. Compile
    2. Install
    3. Clean Up
- You can choose to run any 1 or all of these steps when you run the script.
- Please do not run the Clean Up step until you are finished installing and have verified it is working.
        
```
wget https://raw.githubusercontent.com/crypto-guys/near-guildnet/main/nearcore/install/install.sh
chmod +x install.sh
sudo ./install.sh
```

The installer script has an option to enter the validator name so the validator key is generated correctly


## Use

### Using the install script

- This script can be used to compile any version of nearcore from any repo you specify see lines 8 thru 11 of install.sh
- sudo ./install.sh

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

