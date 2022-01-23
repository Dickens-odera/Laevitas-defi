const MainPriceFeedConsumer = artifacts.require('MainPriceFeedConsumer');

module.exports = function(deployer, network){
    //Opyn ropsten adresses
    const ropstenControllerAddress = '0x59F0c781a6eC387F09C40FAA22b7477a2950d209';
    const ropstenOracleAddress = '0xBD9F4bE886653177D22fA9c79FD0DFc41407fC89';

    //Opyn mainnet addresses
    const MAINNET_CONTROLLER_ADDRESS = '0x64187ae08781B09368e6253F9E94951243A493D5';
    const MAINNET_ORACLE_ADDRESS = '0x65D66c76447ccB45dAf1e8044e918fA786A483A1';
    
    if (network === 'ropsten') {
        deployer.deploy(MainPriceFeedConsumer, ropstenControllerAddress, ropstenOracleAddress);
    } else if(network === 'mainnet'){
        deployer.deploy(MainPriceFeedConsumer, MAINNET_CONTROLLER_ADDRESS, MAINNET_ORACLE_ADDRESS);
    }
}