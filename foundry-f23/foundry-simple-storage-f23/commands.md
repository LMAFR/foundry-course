## To create project
forge init
 
## To compile
forge build 

## To deploy
anvil
forge create CompiledContractName --rpc-url localhostUrl --private-key privateKey 
forge script script/DeploySimpleStorage.s.sol --broadcast --rpc-url http://localhost:8545 --private-key {private_key}
cast --to-base {encoded_value} dec

source .env

## Keystore

cast wallet import {new_keystore_name} --interactive 
name: defaultKey
address: 0xf39fd6e51aad88f6f4ce6ab8827279cfffb92266

name: account1
address: 0x1c57fc2ad7b7fe1351461c95366022707c6872ef

Adding a .passwords file is not the best idea, but even if we accidentally push it to Github, it won't be so problematic as if we would
have pushed our private key. In any case, as we are here to learn and practice, I will add that file (and I will also add it to .gitignore)

We could then use --password-file {path} as additional argument for the line below.

The encrypted private key can be found in ./foundry/keystores in a file named as {new_keystore_name}, but we will just find a strange JSON

\\wsl.localhost\Ubuntu\home\algio\.foundry\keystores. *NOTE: IDK WHY BUT IF I ADD THAT ARGUMENT, IT RETURNS AN ERROR.

It has been encripted using "ERC-2335: BLS12-381 Keystore" 

forge script script/DeploySimpleStorage.s.sol --rpc-url=$RPC_URL --account defaultKey --sender 0xf39fd6e51aad88f6f4ce6ab8827279cfffb92266  --broadcast -vvvv

## Run contract function from command line:
    cast send {contract_address} "{function_name({arguments_types})}" {input_value} --rpc-url $RPC_URL --account {keystore_name}
## Run contract function that does not imply sending a transaction (view functions):
    cast call {contract_address} "{function_name()}"
It does not ask for a private key because it does not do any transaction.
### Read results
The result will be given in hexadecimal way, so we will have to convert it to decimal if we want to understand its content:
    cast --to-base {result_from_previous_line} dec

# Foundryup installation (for foundryup-zksync)

Enter this into your WSL terminal:

curl -L https://raw.githubusercontent.com/matter-labs/foundry-zksync/main/install-foundry-zksync | bash

Then, if you enter foundryup, you come back to vanilla-foundry and, if you enter foundryup-zksync, you go to foundry-zksync.

You can check where you are using forge build --help and looking for arguments starting at "zk"

## Build project with foundry-zksync

forge build --zksync

## To deploy with create

forge create src/{contract_to_deploy}:{contract_to_deploy} --rpc-url {RPC_URL} --zksync --legacy

In this case, if you do not deploy a local zksync node with docker, you can use anvil-zksync in the same way we used anvil with
vanilla-foundry.

## To deploy with script

To the date of the class when this issue is showed, it is not explained because it does not seem to be working very well.

## Deploy local zksync node with Docker + Node + Zksync CLI

It does not seem hard, but I will not do because I do not want to install docker in the laptop I am currently working. It is done
in class 29, so I can come back to it later.








