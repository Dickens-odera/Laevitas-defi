const PriceFeedConsumer = artifacts.require("PriceFeedConsumer");
const MockController = artifacts.require('MockSqueethController');
const MockOracle = artifacts.require('MockSqueethOracle');
const MockUSDC = artifacts.require('MockUSDC');
const MockWETH = artifacts.require('MockWETH');
const MockosQueethToken = artifacts.require('MockoSQUEETH');


contract("PriceFeedConsumer",  (accounts) => {
  let priceFeedConsumer;
  let chainLinkOraclePriceFeed;
  let mockController;
  let mockOracle;
  let mockUSDC;
  let mockWETH;
  let mockoSQTH;

  beforeEach(async() => {
    [owner, alice, bob ] = accounts;
    priceFeedConsumer = await PriceFeedConsumer.deployed();
    chainLinkOraclePriceFeed = '0x5f4eC3Df9cbd43714FE2740f5E3616155c5b8419';
    mockController = await MockController.deployed();
    mockOracle = await MockOracle.deployed();
    mockUSDC = await MockUSDC.deployed();
    mockWETH = await MockWETH.deployed();
    mockoSQTH = await MockosQueethToken.deployed();
  });

  describe("deployment", () => {
    it("deploys successfully", async() => {
      assert(priceFeedConsumer,"Price Feed Consumer contract deployed successfully");
    });
  });

  describe("mocks", async() => {
    it('can set the index price(ETH^2)', async() => {

    });
  });

  describe("price data", () => {
    it("should fetch the latest ETH/USD price from onchain price feed oracle", async() => {
      const latestETHPrice = await priceFeedConsumer.getEthPrice();
    });
  });
});
