const MockSqueethOracle = artifacts.require('MockSqueethOracle');

module.exports = function(deployer){
    deployer.deploy(MockSqueethOracle);
}