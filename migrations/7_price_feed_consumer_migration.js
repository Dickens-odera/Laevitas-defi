const PriceFeedConsumer = artifacts.require('PriceFeedConsumer');
const MockSqueethOracle = artifacts.require('MockSqueethOracle');
const MockSqueethController = artifacts.require('MockSqueethController');

const ROPSTEN_CONTROLLER_ADDRESS = '0x59F0c781a6eC387F09C40FAA22b7477a2950d209';
const ROPSTEN_SQUEETH_ORACLE_ADDRESS = '0xBD9F4bE886653177D22fA9c79FD0DFc41407fC89';

const MAINNET_CONTROLLER_ADDRESS = '0x64187ae08781B09368e6253F9E94951243A493D5';
const MAINNET_ORACLE_ADDRESS = '0x65D66c76447ccB45dAf1e8044e918fA786A483A1';

module.exports = function (deployer, network){
    const mockController = MockSqueethController.deployed();
    const mockOracle = MockSqueethOracle.deployed();
    if(network === 'ropsten'){
        deployer.deploy(PriceFeedConsumer, ROPSTEN_CONTROLLER_ADDRESS, ROPSTEN_SQUEETH_ORACLE_ADDRESS);
    }else if(network === 'mainnet'){
        deployer.deploy(PriceFeedConsumer, MAINNET_CONTROLLER_ADDRESS, MAINNET_ORACLE_ADDRESS);
    }else{
        deployer.deploy(PriceFeedConsumer, mockController.address, mockOracle.address);
    }
}