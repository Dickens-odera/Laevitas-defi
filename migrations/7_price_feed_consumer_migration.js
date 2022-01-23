const PriceFeedConsumer = artifacts.require('PriceFeedConsumer');
const MockSqueethOracle = artifacts.require('MockSqueethOracle');
const MockSqueethController = artifacts.require('MockSqueethController');

const CONTROLLER_ADDRESS = '0x64187ae08781B09368e6253F9E94951243A493D5';
const SQUEETH_ORACLE_ADDRESS = '0x65D66c76447ccB45dAf1e8044e918fA786A483A1';

module.exports = async(deployer) => {
    const oracle = await MockSqueethOracle.deployed();
    const controller = await MockSqueethController.deployed();

    deployer.deploy(PriceFeedConsumer, controller.address, oracle.address);
}