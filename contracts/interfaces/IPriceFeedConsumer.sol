// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;
pragma abicoder v2;

interface IPriceFeedConsumer{
    function getSquEthPrice(
        address _pool,
        address _base,
        address _quote,
        uint32 _period,
        bool _checkPeriod
    ) external view returns(uint);
    function getEth2Price(uint _period) external view returns(uint);
    function getMarkPrice(uint _period) external view returns(uint);
    function getOSQthPrice() external view returns(uint);
}