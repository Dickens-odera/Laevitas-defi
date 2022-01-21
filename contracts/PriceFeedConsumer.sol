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

    address internal immutable OSQTH_ADDRESS = 0xf1B99e3E573A1a9C5E6B2Ce818b617F0E664E86B;
    address internal immutable ETH_USD_ORACLE = 0x5f4eC3Df9cbd43714FE2740f5E3616155c5b8419;

    constructor() public{}

    function getEthPrice() public view override returns(uint){

    }

    function getEth2Price() public view override returns(uint){

    }

    function getMarkPrice() public view override returns(uint){

    }

    function getOSQthPrice() public view override returns(uint){

    }

}