// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

interface IPriceFeedConsumer{
    function getEthPrice() external returns(uint);
    function getEth2Price() external returns(uint);
    function getMarkPrice() external returns(uint);
    function getOSQthPrice() external returns(uint);
}