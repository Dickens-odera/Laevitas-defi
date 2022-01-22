const MockWETHToken = artifacts.require('MockWETH');

module.exports = function (deployer) {
    const initialSupply = 10000;
    deployer.deploy(MockWETHToken, initialSupply);
}
