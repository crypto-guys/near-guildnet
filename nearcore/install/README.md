# This bash script will compile nearcore from source for use on the NEAR Guildnet Network. 

# Requirements

- I use a base ubuntu 20.04 image. The only modification made to the os was to set up a username to use during the build process. This script will build a new validator node. **If you are upgrading a validator with data already on it this script will probably not work until I make more changes.**
- The script is split into 2 parts. 
  - Part 1: Install commpiling tools and compile the chosen nearcore version. 
  - Part 2: Moves the files to their destinations and creates a systemd service
    - Note: It is not absolutly required to run Part 1 and Part 2 on the same machine but you would need to copy /tmp/src/guildnet/target/release/ to the new machine if you wanted to do it that way.
    
# Instructions

- First edit part1.sh and enter your validators accountId and save it.

```
sudo chmod +x part*
./part1.sh
sudo su
./part2.sh
exit
```

# Use

### Enabling the service on boot
- ```sudo systemctl enable near-guildnet-validator.service```

### Starting the service 
- ```sudo systemctl start near-guildnet-validator.service```

### Check service status
- ```sudo systemctl status near-guildnet-validator.service```

### Logging

- ```tail /var/log/guildnet.log --follow```
- ```cat /var/log/guildnet.log```
