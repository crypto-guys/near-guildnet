## Description

This script will create a contained environment where we can build our binary files and then with the remove script we destroy the environment when finished with it. We could do many different things depending on our environment. For example you could modify the script to export the container to a file located on a network drive so it could be used again the next time we need to compile. If your using an LXD cluster you would now have a container for compiling your nearcore software with many options available to you.

This keeps our host machine clean of any extra packages that could introduce security issues or unexpected behaviour. This is a list of packages the script installs on the host machine ***"snapd squashfs-tools git curl python3"*** you could remove git, python3, and curl from the script and use a minimal ubuntu install to get a smaller footprint. 

Docker does the same thing as LXD / LXC just in a slightly different way. Our script will do the following 

- Compile nearcore-1.16.2 for guildnet 
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
- This script can be used to compile any version of nearcore from any repo you specify see lines 8 thru 11 of install.sh
- You can remove everything and start over using the remove.sh script --- can be useful if you run into problems.
- When answering question use y for Yes and anything else is no
        
```
wget https://raw.githubusercontent.com/crypto-guys/near-guildnet/main/nearcore/install/install.sh
chmod +x install.sh
sudo ./install.sh
```

The installer script has an option to enter the validator name so the validator key is generated correctly


## Use

### Starting the install script
- ```sudo ./install.sh```

#### Enable the service to start on boot 
- ```systemctl enable /usr/lib/systemd/neard.service```

#### Starting the service
- ```sudo systemctl start neard-guildnet.service```

#### Stopping the service
- ```sudo systemctl stop neard-guildnet.service```

#### Show service status information
- ```sudo systemctl status near-guildnet.service```

#### Logging

**By default all logging information is sent to the journal. For more information see journalctl --help**

If you prefer logs to go to a file uncomment the noted line in the neard-guildnet unit file.

- Quick check to see the validators most recent status
    ```sudo systemctl status near-guildnet.service```

- View logs

    - get all unit file records
    ```sudo journalctl -a -u neard-guildnet ```  
    
    - follow the unit file journal
    ```sudo journalctl -u neard-guildnet -f``` 
    
    -  follow the journal
    ```sudo journalctl -f ```
    
    - Get help
    ```journalctl --help```

