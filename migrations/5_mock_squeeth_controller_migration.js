const MockSqueethController = artifacts.require('MockSqueethController');

module.exports = function(deployer){
    deployer.deploy(MockSqueethController);
}