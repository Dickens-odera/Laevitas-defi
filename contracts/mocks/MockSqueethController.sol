// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;
pragma abicoder v2;

import '@openzeppelin/contracts/access/Ownable.sol';
import '@openzeppelin/contracts/utils/Counters.sol';
import '@openzeppelin/contracts/utils/math/SafeMath.sol';

/**
* @title MockSqueethController
* @dev A Mock Controller for testing out the Squeeth controller implementation
 */
contract MockSqueethController is Ownable{
    using SafeMath for uint256;
    using Counters for Counters.Counter;

    mapping(uint => uint) public indexByDuration; //mock index price(ETH^2) price
    mapping(uint => uint) public denormalizedMarkPrice; //mock denormalizedMarkPrice
    mapping(uint => uint) public denormalizedMarkPriceForFunding; // mock denormalizedmarkForFunding
    mapping(uint => bool) public isExistingMarkPricePeriod; //to check if this rate is already added(for test purposes)

    uint public currentPosition = 1;
    uint public totalIndexPrices = 0;
    uint public totalMarkPrices = 0;

    uint public volatilityPrice = 1;
    uint public transactionPeriod; //dummy transaction period to be set by the contract owner(for testing purposes)

    Counters.Counter private indexIds;
    Counters.Counter private markPriceIds;
    Counters.Counter private denormalizedMarkPriceForFundingIds;

    constructor() public{

    }

    modifier isValidDuration(uint _duration){
        require(_duration != 0,"Invalid Duration");
        _;
    }

    modifier periodIsNotRegistered(uint _period){
        require(isExistingMarkPricePeriod[_period] == false,"Transaction Duration Exists");
        _;
    }

    modifier periodIsRegistered(uint _period){
        require(isExistingMarkPricePeriod[_period] == true,"Transaction Duration Not Registered");
        _;
    }

    event NewIndex(address indexed caller, uint indexed newIndex, uint indexed date); // new ETH^2 price
    event NewMarkPrice(address indexed user, uint indexed newMarkprice, uint indexed date);
    event NewTransactionPeriod(address indexed user, uint indexed newTxPeriod, uint indexed date);
    event NewDenormalizedMarkPriceForFunding(address indexed user, uint indexed newFundingMarkPrice, uint indexed date);

    /**
    * @dev sets a mock transaction period
    * @return bool true if new tx period is set successfully otherwise false
    */
    function setTransactionPeriod(uint _period) public onlyOwner isValidDuration(_period) periodIsNotRegistered(_period) returns(bool){
        transactionPeriod = _period;
        isExistingMarkPricePeriod[_period] = true;
        emit NewTransactionPeriod(msg.sender, _period, block.timestamp);
        return true;
    }

    /**
    * @dev sets a new (ETH^2) price
    * @param _period uint the period for the ETH^2 trading
    * @return bool true is new ETH^2 price is set successfully otherwise false
    */
    function setIndex(uint _period) public onlyOwner isValidDuration(_period) returns(bool){
        indexIds.increment();
        uint currentIndexId = indexIds.current();
        indexByDuration[_period] = currentIndexId;
        totalIndexPrices = totalIndexPrices.add(1); // to prevent integer overflow
        emit NewIndex(msg.sender,currentIndexId, block.timestamp);
        return true;
    }

    /**
    * @dev sets a new PowerPerp mark price
    * @param _period the duraion of the trade
    * @return bool true if new price is set successfully otherwisw false
    */
    function setDenormalizedMark(uint _period) public onlyOwner isValidDuration(_period) returns(bool){
        markPriceIds.increment();
        uint currentDenormalizedMarkPrice = markPriceIds.current();
        denormalizedMarkPrice[_period] = currentDenormalizedMarkPrice;
        totalMarkPrices = totalMarkPrices.add(1);
        emit NewMarkPrice(msg.sender,currentDenormalizedMarkPrice, block.timestamp);
        return true;
    }
    
    /**
    * @dev sets a
    * @param _period uint the funding period
    * @return true if new funding period is set otherwise false
    */
    function setDenormalizedMarkForFunding(uint _period) public onlyOwner isValidDuration(_period) returns(bool){
        denormalizedMarkPriceForFundingIds.increment();
        uint currentDenFundIdForFunding = denormalizedMarkPriceForFundingIds.current();
        denormalizedMarkPriceForFunding[_period] = currentDenFundIdForFunding;
        emit NewDenormalizedMarkPriceForFunding(msg.sender, currentDenFundIdForFunding, block.timestamp);
        return true;
    }

    /**
    * @dev get the index price of the powerPerp, scaled down
    * @return index price denominated in $USD
    */
    function getIndex(uint _period) public view periodIsRegistered(_period) returns(uint){
        return indexByDuration[_period];
    }

    /**
    * @dev get the expected mark price of powerPerp after funding has been applied
    * @return uint the powerPer price based on the trading period
    */
    function getDenormalizedMark(uint _period) public view periodIsRegistered(_period) returns(uint){
        return denormalizedMarkPrice[_period];
    }

    /**
    * @dev get the mark price of powerPerp before funding has been applied
    * @return uint mark price
    */
    function getDenormalizedMarkForFunding(uint _period) public view periodIsRegistered(_period) returns(uint){
        return denormalizedMarkPriceForFunding[_period];
    }

    /**
    * returns the price volatility between the trades of ETH^2 and oSQTH
    */
    function getVolatilityPrice() public view returns(uint){
        return volatilityPrice;
    }

    /**
    * @dev gets the funding rates based on the proived period
    * @return uint the calucalted funding rate
    */
    function getCurrentFundingRate(uint _period) public view periodIsRegistered(_period) returns(uint){
        uint markPrice = getDenormalizedMark(_period);
        uint indexPrice = getIndex(_period);
        return _getCurrentFundingRate(markPrice,indexPrice);
    }

    /**
    * @dev returns the funding rate based on an average of the two toke prices(mark price and index price) 
    * for testing only and not the exact implementation from squeeth protocol
    */
    function getHistoricalFundingRate(uint _periodFrom, uint _periodTo) public view returns(uint){
        require(_periodFrom != _periodTo,"Invalid Period Range");
        require(_periodTo > _periodFrom,"Period To must be greator than the initial range");
        require(_periodTo != 0,"Final Period Range cannot be zero");
        require(_periodFrom > 0,"Intitial Period Range must not be zero");

        uint initialMarkPrice = getDenormalizedMark(_periodFrom);
        uint latestMarkPrice =  getDenormalizedMark(_periodTo);

        uint totalMarkPrice = initialMarkPrice.add(latestMarkPrice);
        uint avgMarkPrice = totalMarkPrice.div(2);

        uint initialIndexPrice = getIndex(_periodFrom);
        uint latestIndexPrice = getIndex(_periodTo);

        uint totalIndexPrice = initialIndexPrice.add(latestIndexPrice);
        uint avgIndexPrice = totalIndexPrice.div(2);

        return _getHistoricalFundingRate(avgMarkPrice,avgIndexPrice);
    }

    /**
    * @notice Funding rates are payments made by long Squeeth traders to short Squeeth traders 
    * based on the disparity between the Index Price (ETH²) and the Mark Price
    * @dev a helper function that calculates the current funding rate from the mark price(ETH^2 price and index price )
    */
    function _getCurrentFundingRate(uint _markPrice, uint _indexPrice) internal view returns(uint){
        uint difference = _markPrice.sub(_indexPrice);
        uint position = _getCurrentPosition();
        return position.mul(difference);
    }

    /**
    * @dev internal functin that calculates the funding rates
    */
    function _getHistoricalFundingRate(uint _avgMarkPrice, uint _avgIndexPrice) internal view returns(uint){
        return _getCurrentFundingRate(_avgMarkPrice,_avgIndexPrice);
    }

    /**
    * @dev fetches the user\'s current token position
    */
    function _getCurrentPosition() internal view returns(uint){
        return currentPosition;
    }
}