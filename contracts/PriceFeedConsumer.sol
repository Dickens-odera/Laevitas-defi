// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;
import '@openzeppelin/contracts/access/Ownable.sol';
import '@openzeppelin/contracts/utils/math/SafeMath.sol';

import './interfaces/IPriceFeedConsumer.sol';

/**
 * @title PriceFeed Contract
 * @dev A simple contract that interacts with external contracts by fetching token price data
 */
contract PriceFeedConsumer is Ownable, IPriceFeedConsumer{
    using SafeMath for uint256;

    constructor() public{}

    function getEthPrice() public override returns(uint){

    }

    function getEth2Price() public override returns(uint){

    }

    function getMarkPrice() public override returns(uint){

    }

    function getOSQthPrice() public override returns(uint){

    }

}