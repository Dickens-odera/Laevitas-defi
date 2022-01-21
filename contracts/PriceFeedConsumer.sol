// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;
import '@openzeppelin/contracts/access/Ownable.sol';
import '@openzeppelin/contracts/utils/math/SafeMath.sol';
import '@chainlink/contracts/src/v0.8/interfaces/AggregatorV3Interface.sol';

import './interfaces/IPriceFeedConsumer.sol';

/**
 * @title PriceFeed Contract
 * @dev A simple contract that interacts with external contracts by fetching token price data
 */
contract PriceFeedConsumer is Ownable, IPriceFeedConsumer{
    using SafeMath for uint256;

    address internal constant OSQTH_ADDRESS = 0xf1B99e3E573A1a9C5E6B2Ce818b617F0E664E86B;
    address internal constant KOVAN_ETH_USD_ORACLE = 0x9326BFA02ADD2366b30bacB125260Af641031331;

    AggregatorV3Interface internal priceFeed; //instantiate an oracle pricefeed

    constructor() public{
        priceFeed = AggregatorV3Interface(KOVAN_ETH_USD_ORACLE);
    }

    /**
    * @dev get the latest price of ETH in USD from the oracle price feed
    */
    function getEthPrice() public view override returns(int){
        (,int price,,,) = priceFeed.latestRoundData();
        return price;
    }

    function getEth2Price() public view override returns(uint){

    }

    function getMarkPrice() public view override returns(uint){

    }

    function getOSQthPrice() public view override returns(int){

    }
}