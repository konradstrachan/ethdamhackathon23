
# Token Vesting

## Description

This repository contains the project developed during the ETHDam privacy event in Amsterdam hackathon. Token Vesting is a proof of concept for a general purpose contract that can be used to escrow funds that are released on a certain time schedule.

It was developered not only to experiment with the idea of trustless vesting, but also an excuse to build a smart contract to experiment with the Scroll zkEVM alpha testnet (https://scroll.io/).

The PoC contract is deployed at https://blockscout.scroll.io/address/0xD8a5a9b31c3C0232E196d518E89Fd8bF83AcAd43

The Solidity smart contract implements a token vesting mechanism that allows users to stake ERC20 tokens and gradually release them over a predefined vesting period. The contract supports multiple beneficiaries, each with their own vesting schedules for different tokens.

## Features

* Multiple beneficiaries can have staked ERC20 tokens
* Each beneficiary can have multiple vesting schedules for different tokens
* The vesting schedules include a cliff time and an end time
* Beneficiaries cannot withdraw funds before the cliff time
* The amount available for withdrawal is restricted based on the elapsed time since the cliff time
* Withdrawn funds are transferred from the contract to the beneficiary
* The contract is compatible with any ERC20 token that implements the transfer and transferFrom functions

## Technologies Used
* Solidity for smart contract development 
* React, Hardhat, NextJS for rapid prototying and testing (via Scaffold-ETH 2)

## Usage

### Stake Funds: stakeFunds

Stakers can provide funds to beneficiaries by transferring ERC20 tokens to the contract by calling the stakeFunds function and providing the following parameters:

* beneficiary: The address of the beneficiary who will receive the tokens
* tokenAddress: The address of the ERC20 token to be staked
* cliffTime: The timestamp representing the start of the token unlock (cliff time) after which funds can begin to be withdrawn
* endTime: The timestamp representing the end of the vesting period by which point all tokens will be fully available to be withdrawn
* totalAmount: The total amount of tokens to be vested

### Withdraw Funds: withdrawFunds

Beneficiaries can withdraw their vested funds after the start of the unlock period (cliff time) by calling the withdrawFunds function and specifying the token and schedule index to withdraw from.

Since a beneficiary might have multiple tokens (or multiple unlocks of the same token for different times) they should call this function with the correct parameters.

* tokenAddress: token being claimed
* scheduleIndex: which stake is being claimed

Assuming a vesting period cliff time has passed and funds are not yet claimed, they will be transferred from the contract to the beneficiary's address.

### Check Pending Stakes: getStakesForBeneficiary

Beneficiaries can check their pending vesting schedules by calling the getStakesForBeneficiary function and providing their address and the token address.

The function returns an array of VestingSchedule objects that represent the pending vesting schedules.

## Events

The contract emits the following events:

* FundsStaked: Emitted when funds are staked in the contract. Contains information about the beneficiary, token, total amount, cliff time, and end time.

* FundsWithdrawn: Emitted when funds are withdrawn from the contract. Contains information about the beneficiary, token, schedule index, and amount.

## Deployment

The contract can be deployed on any EVM network like Ethereum or the Scroll zkEVM network using a compatible development framework.

For this project I used https://github.com/scaffold-eth/scaffold-eth-2 which contains all the tools needed to build, compile and deploy.

## License
This project is licensed under the MIT License.

## Disclaimer

This smart contract is the product of a few hours of rapid prototyping as part of a Hackathon. Care was taken to ensure it is free from defects and security vulnerabilities but it should not be considered production ready and is thus provided as-is without any warranty. 

Anyone wishing to use this should exercise caution and perform due diligence before using this contract in a production environment.