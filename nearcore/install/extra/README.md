# Hetzner Cloud Installer


## Description

This is a cloud-init file can be used with hetzner cloud services. This file is capable of producing NEAR validator node from source automatically.

## Requirements

1. The sshd_config that is provided with this script only allows Pubkey authentication. If you wish to use anything else change the script or provide your own sshd_config
2. You must provide your ssh public key in the file where it says authorized keys
3. Scripts are to be encoded using base64 with no line wrapping.

## Instructions

- Create a new server in the hetzner cloud console.
- Paste the contents of basic-cloud-init.yaml into the user info section
- Create the server

- When the server is finished compiling and installing software a message is sent to /var/log/syslog this message contains the word finally so.....
```
cat /var/log/syslog | grep finally
```

- Enable and start the service
```
sudo systemctl enable neard && sudo systemctl start neard
```

more to come this isnt complete yet
