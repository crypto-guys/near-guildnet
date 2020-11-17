# This bash script will compile nearcore from source for use on the NEAR Guildnet Network. 

# Requirements

- I use a base ubuntu 20.04 image. The only modification made to the os was to set up a username to use during the build process.

# Instructions

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
