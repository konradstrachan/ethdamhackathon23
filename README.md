# Multi-Token transparent vesting

## Description

This repository contains the project developed during the ETHDam hackathon in Amsterdam. Token Vesting is a proof of concept for a general purpose contract that can be used to escrow funds that are released on a certain open and predicatable time schedule.

It was developered not only to experiment with the idea of trustless vesting, but also as an excuse to build a smart contract to experiment with the Scroll zkEVM alpha testnet (https://scroll.io/).

The PoC verified 🚀 contract is deployed at 🔗 https://blockscout.scroll.io/address/0x51A1ceB83B83F1985a81C295d1fF28Afef186E02

The Solidity smart contract implements a token vesting mechanism that allows users to stake ERC20 tokens and gradually release them over a predefined vesting period. The contract supports multiple beneficiaries, each with their own vesting schedules for different tokens.

## Features

* Fully transparent escrowed funds
* Multiple beneficiaries can have staked ERC20 tokens
* Each beneficiary can have multiple vesting schedules for different tokens
* The vesting schedules include a cliff time and an end time completely configurable by the vesting originiator
* Beneficiaries cannot withdraw funds before the cliff time
* The amount available for withdrawal is restricted based on the elapsed time since the cliff time
* Withdrawn funds are transferred from the contract to the beneficiary directly
* The contract is compatible with any ERC20 token that implements the transfer and transferFrom functions (not native ETH/chain tokens currently)

## Technologies Used
* Solidity for smart contract development
* React, Hardhat, NextJS for rapid prototying and testing (via Scaffold-ETH 2)
* Scroll for deploying and demoing contracts

## Usage

Smart contract public function reference:

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

## Worked example

👨 Bob wants to pay Alice 10,000 USDT for a year of contributions to his project.
👨 He wants to demonstrate good faith but doesn't want to pay up front.

💸 Bob depsits 10,000 USDT using the stakeFunds call nominating Alice as the beneficiary.
⌛ Bob also sets the cliff to be in 6 months time with a full availability of funds after 1 year.

![image](https://github.com/konradstrachan/ethdamhackathon23/assets/21056525/704b3299-7ebb-4307-81ae-5b3710f7233e)

👒 Alice sees the funds sent to the Vesting contract nominating her as a beneficiary and when she can begin to claim.
💰 After 6 months, Alice can linearly claim more and more of the funds as they unlock by calling withdrawFunds.

🤗 Alice is happy.

https://github.com/konradstrachan/ethdamhackathon23/assets/21056525/e65c9308-6d1e-4d5f-88f0-2d1ddeb33a01

This example is shown in a screen recording of the interaction, also available at https://www.youtube.com/watch?v=CGLAxcE440c.

In this recording the Vesting contract at 0xA51c1fc2f0D1a1b8494Ed1FE312d7C3a78Ed91C0 is used with a test ERC20 token deployed to 0xa513E6E4b8f2a923D98304ec87F64353C4D5C853.
For simplicity, both Bob and Alice share the address 0x800Fe78384450Ecb26418f61C6e16d9FA7877fA8.

## Deployment

The contract can be deployed on any EVM network like Ethereum or the Scroll zkEVM network using a compatible development framework.

For this project I used https://github.com/scaffold-eth/scaffold-eth-2 which contains all the tools needed to build, compile and deploy.

## License
This project is licensed under the MIT License.

## Disclaimer

This smart contract is the product of a few hours of rapid prototyping as part of a Hackathon. Care was taken to ensure it is free from defects and security vulnerabilities but it should not be considered production ready and is thus provided as-is without any warranty. 

Anyone wishing to use this should exercise caution and perform due diligence before using this contract in a production environment.
