// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;
pragma abicoder v2;

import '@openzeppelin/contracts/access/Ownable.sol';
import '@openzeppelin/contracts/utils/math/SafeMath.sol';
import '@chainlink/contracts/src/v0.8/interfaces/AggregatorV3Interface.sol';
//import 'https://github.com/opynfinance/squeeth-monorepo/blob/main/packages/hardhat/contracts/interfaces/IController.sol';
//import 'https://github.com/opynfinance/squeeth-monorepo/blob/main/packages/hardhat/contracts/core/Controller.sol';

import './IPriceFeedConsumer.sol';
//import './IController.sol';


interface SqueethProtocolInterface {
    function getIndex(uint _period) external view returns(uint);
    function getDenormalizedMark(uint _period) external view returns(uint);
    function getDenormalizedMarkForFunding(uint _period) external view returns(uint);
    function getExpectedNormalizationFactor() external view returns(uint);
    function getVolatilityPrice() external view returns(uint);
}

/**
 * @title PriceFeed Contract
 * @dev A simple contract that interacts with external contracts by fetching token price data
 */
contract PriceFeedConsumer is IPriceFeedConsumer{
    using SafeMath for uint256;
    
    address internal constant OSQTH_ADDRESS = 0xf1B99e3E573A1a9C5E6B2Ce818b617F0E664E86B;
    address internal constant KOVAN_ETH_USD_ORACLE = 0x9326BFA02ADD2366b30bacB125260Af641031331;
    address internal constant SQUEETH_CONTROLLER = 0x64187ae08781B09368e6253F9E94951243A493D5;

    AggregatorV3Interface internal priceFeed; //instantiate an oracle pricefeed
    //Controller internal controller;

    address public immutable squeethProtocol;

    constructor(address _protocol) public{
        squeethProtocol = _protocol;
        priceFeed = AggregatorV3Interface(KOVAN_ETH_USD_ORACLE);
    }

    /**
    * @dev returns the latest price of ETH in USD from the chaainlink oracle price feed
    */
    function getEthPrice() public view override returns(int){
        (,int price,,,) = priceFeed.latestRoundData();
        return price;
    }

    /**
    * @dev returns the latest ETH(2) price in USD from the squeeth protocol
    */
    function getEth2Price() public view override returns(uint){

    }

    /**
    * @dev get the expected mark price of powerPerp after funding has been applied
    * @param _period uint
    */
    function getMarkPrice(uint _period) public view override returns(uint){
        return SqueethProtocolInterface(squeethProtocol).getDenormalizedMark(_period);
    }

    /**
    * @dev get the latest squeeth price in USD 
    */
    function getOSQthPrice() public view override returns(int){

    }

    /**
    * @dev returns implied volatility of the squeeth token from the protocol
    */
    function getImpliedVolatility() public view returns(uint){

    }

    function getExpectedNormalizationFactor() external view returns (uint256){
        return SqueethProtocolInterface(squeethProtocol).getExpectedNormalizationFactor(_period);
    }

}