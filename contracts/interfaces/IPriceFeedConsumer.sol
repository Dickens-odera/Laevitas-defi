// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

interface IPriceFeedConsumer{
    function getEthPrice() external view returns(int);
    function getEth2Price() external view returns(uint);
    function getMarkPrice() external view returns(uint);
    function getOSQthPrice() external view returns(uint);
}