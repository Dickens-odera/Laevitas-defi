// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;
pragma abicoder v2;

import '@openzeppelin/contracts/access/Ownable.sol';
import '@openzeppelin/contracts/utils/math/SafeMath.sol';
import '@chainlink/contracts/src/v0.8/interfaces/AggregatorV3Interface.sol';
//import 'https://github.com/opynfinance/squeeth-monorepo/blob/main/packages/hardhat/contracts/interfaces/IController.sol';
//import 'https://github.com/opynfinance/squeeth-monorepo/blob/main/packages/hardhat/contracts/core/Controller.sol';

import './interfaces/IPriceFeedConsumer.sol';

interface SqueethProtocolInterface {
    function getIndex(uint _period) external view returns(uint);
    function getDenormalizedMark(uint _period) external view returns(uint);
    function getDenormalizedMarkForFunding(uint _period) external view returns(uint);
    function getExpectedNormalizationFactor() external view returns(uint);
    function getVolatilityPrice() external view returns(uint);
    function getCurrentFundingRate() external view returns(uint);
    function getHistoricalFundingRate() external view returns(uint);
}

interface SqueethOracleInterface{
    function getTwap(
        address _pool,
        address _base,
        address _quote,
        uint32 _period,
        bool _checkPeriod
    ) external view returns (uint256);

    function getHistoricalTwap(
        address _pool,
        address _base,
        address _quote,
        uint32 _secondsAgoToStartOfTwap,
        uint32 _secondsAgoToEndOfTwap
    ) external view returns (uint256);
}

/**
 * @title PriceFeed Contract
 * @dev A simple contract that interacts with external contracts by fetching token price data
 */
contract PriceFeedConsumer is IPriceFeedConsumer,Ownable{
    using SafeMath for uint256;
    
    address internal constant OSQTH_TOKEN_ADDRESS = 0xf1B99e3E573A1a9C5E6B2Ce818b617F0E664E86B;
    address internal constant SQUEETH_CONTROLLER = 0x64187ae08781B09368e6253F9E94951243A493D5;
    address internal constant SQUEETH_ORACLE = 0x65D66c76447ccB45dAf1e8044e918fA786A483A1;
    address internal constant SQU_ETH_UNI_V3_POOL = 0x82c427AdFDf2d245Ec51D8046b41c4ee87F0d29C;
    address internal constant ETH_USDC_UNI_V3_POOL = 0x8ad599c3A0ff1De082011EFDDc58f1908eb6e6D8;
    address internal constant WETH_TOKEN_ADDRESS = 0xC02aaA39b223FE8D0A0e5C4F27eAD9083C756Cc2;
    address internal constant USDC_TOKEN_ADDRESS = 0xA0b86991c6218b36c1d19D4a2e9Eb0cE3606eB48;
    address public immutable CHAINLINK_KOVAN_ETH_USD_ORACLE = 0x9326BFA02ADD2366b30bacB125260Af641031331;

    AggregatorV3Interface internal priceFeed; //instantiate an oracle pricefeed

    address public immutable squeethProtocol;
    address public immutable squeethOracle;

    constructor(address _protocol, address _squeethOracle) public{
        squeethProtocol = _protocol;
        squeethOracle = _squeethOracle;
        priceFeed = AggregatorV3Interface(CHAINLINK_KOVAN_ETH_USD_ORACLE);
    }

    /**
    * @dev returns the latest price of ETH in USD from the chaainlink oracle price feed
    */
    function getChainLinkEthPrice() public view returns(int){
        (,int price,,,) = priceFeed.latestRoundData();
        return price;
    }

    /**
    * @dev get the ETH/USDC price from the Squeeth Uniswap V3 Pool
    */
    function getSquUniswapPoolEthPrice(
        address _pool,
        address _base,
        address _quote,
        uint32 _period,
        bool _checkPeriod
    ) public view returns(uint){
        return SqueethOracleInterface(squeethOracle).getTwap(_pool,_base, _quote,_period, _checkPeriod);
    }

    /**
    * @dev returns the latest ETH(2) price (get the index price of the powerPerp, scaled down)
    * @param _period period which you want to calculate twap with
    */
    function getEth2Price(uint _period) public view override returns(uint){
        return SqueethProtocolInterface(squeethProtocol).getIndex(_period);
    }

    /**
    * @dev get the expected mark price of powerPerp after funding has been applied
    * @param _period uint
    */
    function getMarkPrice(uint _period) public view override returns(uint){
        return SqueethProtocolInterface(squeethProtocol).getDenormalizedMark(_period);
    }

    /**
    * @dev get the latest squeeth price in USD from the Squeeth-Uniswap V3 pool
    */
    function getOSQthPrice(
        address _pool,
        uint32 _period,
        bool _checkPeriod
    ) public view override returns(uint){
        return SqueethOracleInterface(squeethOracle).getTwap(_pool,OSQTH_TOKEN_ADDRESS, USDC_TOKEN_ADDRESS,_period, _checkPeriod);
    }

    /**
    * @dev returns implied volatility of the squeeth token from the protocol
    */
    function getImpliedVolatility() public view returns(uint){

    }

    /**
    * @dev calculates the funding rate from the payments made by long Squeeth traders to short Squeeth traders 
    * based on the disparity between the Index Price (ETH²) and the Mark Price (current trading price of Squeeth), 
    * regularly (Mark — Index).
    */
    function getCurrentFundingRate(uint _period) public view returns(uint){
        uint markPrice = getMarkPrice(_period);
        uint indexPrice = getEth2Price(_period);
        uint positionSize = 1;
        uint difference = markPrice.sub(indexPrice);
        return (positionSize.mul(difference) * 10) / 100;
    }

    function getHistoricalFundingRates(uint _period) public view returns(uint){
        //return SqueethProtocolInterface(squeethProtocol).getHistoricalFundingRate();
    }

}