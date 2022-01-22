const MockoSqueethToken = artifacts.require('MockoSQUEETH');

module.exports = function(deployer){
    const initialSupply = 10000;
    deployer.deploy(MockoSqueethToken, initialSupply);
}
