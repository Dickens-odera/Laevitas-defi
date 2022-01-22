// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;
pragma abicoder v2;

import '@openzeppelin/contracts/access/Ownable.sol';
import '@openzeppelin/contracts/token/ERC20/ERC20.sol';

contract MockoSQUEETH is Ownable, ERC20{
    constructor(uint _initialSupply) ERC20("Mock SQUEETH","mOSQTH"){
        _mint(msg.sender,_initialSupply * 10 ** decimals());
    }
}