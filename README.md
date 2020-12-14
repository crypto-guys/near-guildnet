# SETUP A GuildNet NODE
This guide will help you setup a NEAR validator node on Guildnet. We provide step by step instructions to assist even those new to validating. 
We'd appreciate your contribution and feedback on this guide.  

## Content for setting up a node
1.  [Server Requirements](#Server-Requirements)
2.  [Launch validator node](#Launch-validator-node)
3.  [Create a wallet](#Create-a-wallet-on-GuildNet)
4.  [Install Near-Cli](#Install-Near-Cli)
5.  [Setting up Environment](#Setting-up-your-environment)
6.  [Authorize NEAR-Cli](#Authorize-NEAR-Cli)
7.  [Create Staking Pool](#Create-your-staking-pool)
8. [Delegate Tokens](#Delegate-tokens-and-get-rewards)  
9. [Monitor Validator Status](#Monitor-validator-node-status)


## Server Requirements
To become a validator your server will need to meet these minimum requirements:
```bash
At least 2-Core (4-Thread) Intel i7/Xeon equivalent
At least 16GB RAM
At least 100GB SSD (Note: HDD will not work)
```  

You'll be working with two machines, a server for the validator node, and your personal machie/monitor machine to install near-cli, create the wallet, monitor and control the validator node.

### Ubuntu Prerequisite Installation

*To use Nearup On the Server:*

```bash
sudo apt install python3 git curl
```

*To use Compile Script and Systemd:*
```bash
sudo apt install python3 git curl snapd
```

## Launch validator node

### Step 1. Install nearcore on Host

- There are 2 ways to install nearcore currently. You can use Nearup or you can compile the source and use systemd to manage it.

### Option 1 - Use Nearup

- **Step 1.Install Nearup**

On the Server: The Prerequisite has python3, git and curl toolset, which have been installed in previous step. please run command prompt.

curl --proto '=https' --tlsv1.2 -sSfL https://raw.githubusercontent.com/near-guildnet/nearup/master/nearup | python3
Nearup automatically adds itself to PATH: restart the terminal, or issue the command: . ~/.profile. On each run, nearup self-updates to the latest version.

- **Step 2. Choose a staking-pool AccountId**

On the first run, nearup will ask you to enter a staking-pool AccountId, please choose a name for your staking-pool AccountId, it must end with ".stake.guildnet", e.g. *MyStakingPool.stake.guildnet*. 

You should go to [https://near-guildnet.github.io/staking-pool-factory](https://near-guildnet.github.io/staking-pool-factory/) to check if the name is available. Don't create your staking-pool contract yet, just check if the name is available.

- **Step 3. Start nearup guildnet**

We recommand to use Officially Compiled Binary to launch a validator node, which is suitable to run on VPS. Then, input your staking pool ID in the prompt by this command:
```bash
nearup guildnet --nodocker

```

### Option 2 - Compile from source and Use Systemd

- The [readme file](https://github.com/crypto-guys/near-guildnet/blob/main/nearcore/install/README.md)   <------  More Detailed script instructions
- **Step 1** Compile the code - Install The Service
```
wget https://raw.githubusercontent.com/crypto-guys/near-guildnet/main/nearcore/install/install.sh
sudo ./install.sh
```
- **Systemd Usage**

- Enabling the service on boot
```
sudo systemctl enable neard.service
sudo systemctl disable neard.service
```

- Start, Stop, Get Status 
```
sudo systemctl start neard.service

sudo systemctl stop neard.service

sudo systemctl status neard.service
```
- Check the validators log. 
- **Please note:** By default logs go to the system journal 
- This is controlled by the file /usr/lib/systemd/journald.conf.d/neard.conf 

To output logs to the specified file and append data uncomment this line from /usr/lib/systemd/neard.service  
```
#StandardOutput=append:/var/log/guildnet.log
```

- Check the logs
```
sudo journalctl -x -u neard
```
For more information on using journalctl use this command 

```journalctl --help```

Verify your install
```bash
ls /usr/lib/near/guildnet
# validator_key.json  node_key.json  config.json  data  genesis.json
cat /usr/lib/near/guildnet | grep public_key
```
Make sure the name is correct and take note of the public key.

Skip to  [Create a wallet](#Create-a-wallet-on-GuildNet) .....


## Verify your install

Check validator_key.json is generated for staking pool.
```bash
ls ~/.near/guildnet
validator_key.json  node_key.json  config.json  data  genesis.json
cat ~/.near/guildnet/validator_key.json | grep public_key
```
Take note of the **validator public_key** 
```json
    "public_key": "ed25519:**TAKE-NOTE-OF-THIS**"
```

Check running status of validator node. If "V/" is showning up, your pool is selected in current validators list.
```bash
nearup logs -f

# Or if you compiled yourself
sudo journalctl -u neard -f
```

## Create a wallet on GuildNet
*On your personal machine:*
You will need a wallet.  
To create a [guildnet wallet](https://wallet.openshards.io) go to: [https://wallet.openshards.io](https://wallet.openshards.io) be sure to record your wallet address and seed phrase (12 words)  
_Tip: You may request 75,000 faucet from Near team for staking test._  

[GuildNet Faucet](https://near-guildnet.github.io/open-shards-faucet/)

## Install Near-Cli
*On your personal machine:*
NEAR CLI is a Node.js application that relies on near-api-js to generate secure keys, connect to the NEAR platform and send transactions to the network on your behalf.  
_note that Node.js version 10+ is required to run NEAR CLI_   

**Note: You don't need to install Near-Cli on the server. We reccomend to install near-cli on your personal machine or a separate machine for increased security and performance. However it still can be installed on the same machine.**

#### Install Node Version 15.x and npm
Nodes.js and npm can be install by
```bash
curl -sL https://deb.nodesource.com/setup_15.x | sudo -E bash -
sudo apt install build-essential nodejs
PATH="$PATH"
```

#### Check Node.js and npm version  
```bash
node -v
    v15.3.0
npm -v
    7.0.14

```

### Install the guild's near-cli
```bash
git clone https://github.com/crypto-guys/near-cli.git 
cd near-cli/
npm install
sudo npm install -g
```
## Setting up your environment
To use the guildnet network you need to update the environment via the command line.  
Open a command prompt and run
```bash
export NODE_ENV=guildnet
```
Add (export NODE_ENV=guildnet) to the end of the ~/.bashrc file to ensure it persists system restarts.
```bash
echo 'export NODE_ENV=guildnet' >> ~/.bashrc 
```

## Authorize NEAR-Cli
- To authorize NEAR-Cli access you need your keys in the folder ~/.near-credentials/guildnet (if you have your keyfiles here no need to login)
- To use the web wallet to get the keys we need to login via the command prompt.
```bash
near login
```

Subsequently, the browser will be opened, if it does not simply copy and paste the generated link into the browser. You may need to restore your wallet account via Seed Phase. This action will authorize NEAR-cli access to main account via the shell.  
```
We recommend using <your account>.guildnet as main accountId and <your pool>.stake.guildnet as pool ID below.
```
Now, You can manage your main wallet account and smart contract with the NEAR CLI. 
```bash
For account:
  near login                                       # logging in through NEAR protocol wallet
  near create-account <accountId>                  # create a developer account with --masterAccount (required), publicKey and initialBalance
  near state <accountId>                           # view account state
  near keys <accountId>                            # view account public keys
  near send <sender> <receiver> <amount>           # send tokens to given receiver
  near stake <accountId> <stakingKey> <amount>     # create staking transaction (stakingKey is base58 encoded)
  near delete <accountId> <beneficiaryId>          # delete an account and transfer funds to beneficiary account
  near delete-key [accessKey]                      # delete access key
  
For smart contract:
  near deploy [accountId] [wasmFile] [initFunction] [initArgs] [initGas] [initDeposit]  # deploy your smart contract
  near dev-deploy [wasmFile]                       # deploy your smart contract using temporary account (TestNet only)
  near call <contractName> <methodName> [args]     # schedule smart contract call which can modify state
  near view <contractName> <methodName> [args]     # make smart contract call which can view state
  near clean           
```
check your public key file of main account.
```bash
ls ~/.near-credentials/guildnet
staketest.guildnet.json
```

## Create your staking pool
You need to setup a staking pool, the easiest way is to go back to [https://near-guildnet.github.io/staking-pool-factory/](https://near-guildnet.github.io/staking-pool-factory/) with the staking-pool AccountId you selected, and the **validator public_key** you got while starting nearup and complete the process to create the staking-pool contract.

#### Alternative:
You can also setup a staking pool from the command line using the *create_staking_pool* method.
Check public key from ~/.near/guildnet/validator_key.json on your validator server:
```bash
cat ~/.near/guildnet/validator_key.json | grep public_key
```
```bash
near call stake.guildnet create_staking_pool '{"staking_pool_id": "<Pool ID need to be generated>", "owner_id": "<Master Account ID>", "stake_public_key": "<public_key in validator_key.json>", "reward_fee_fraction": {"numerator": 10, "denominator": 100}}' --accountId="<Master Account ID>" --amount=30 --gas=300000000000000
example:
near call stake.guildnet create_staking_pool '{"staking_pool_id": "testpool", "owner_id": "staketest.guildnet", "stake_public_key": "ed25519:4x1LrkFvxnh8Aeh8NQc9cn15XuYAVHA2aN6WVhFfCdaE", "reward_fee_fraction": {"numerator": 10, "denominator": 100}}' --accountId="blaze.guildnet" --amount=30 --gas=300000000000000
```

## Delegate tokens and get rewards
   * As a user, to deposit and stake NEAR tokens
```bash
near call <validator pool ID> deposit_and_stake --amount <amount of tokens> --accountId <main account ID>
example:
near call testpool.stake.guildnet deposit_and_stake --amount 70000 --accountId staketest.guildnet
```
  * To update current rewards:
```bash
near call <validator pool ID> ping '{}' --accountId <main account ID>
example:
near call testpool.stake.guildnet ping '{}' --accountId staketest.guildnet
```
## Monitor validator node status
To be a validator, you can execute Near-cli to monitor and manager validator pool by your main account.  
  * Check if your pool is in proposals at first.
```bash
near proposals | grep testpool.stake.guildnet
```
  * Check if your pool is in current validators list.
```bash
near validators current | grep testpool.stake.guildnet
```  
  * Check if your pool is in next validators list.
```bash
near validators next | grep testpool.stake.guildnet
```    
  * Check the validator seat price.
```bash
near validators current | grep "seat price"
```
If your stake is not enough to get a seat, please participate in the following challenges to get more tokens. (Coming Soon...)
