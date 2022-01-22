const PriceFeedConsumer = artifacts.require('PriceFeedConsumer');

const CONTROLLER_ADDRESS = '0x64187ae08781B09368e6253F9E94951243A493D5';
const SQUEETH_ORACLE_ADDRESS = '0x65D66c76447ccB45dAf1e8044e918fA786A483A1';
module.exports = function(deployer){
    deployer.deploy(PriceFeedConsumer, CONTROLLER_ADDRESS, SQUEETH_ORACLE_ADDRESS);
}