const MockUSDCToken = artifacts.require('MockUSDC');

module.exports = function(deployer){
    const initialSupply = 10000;
    deployer.deploy(MockUSDCToken, initialSupply);
}
