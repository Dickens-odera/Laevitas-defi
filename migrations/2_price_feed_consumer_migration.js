const PriceFeedConsumer = artifacts.require('PriceFeedConsumer');

module.exports = function(deployer){
    deployer.deploy(PriceFeedConsumer);
}