const PriceFeedConsumer = artifacts.require("PriceFeedConsumer");

contract("PriceFeedConsumer", function (accounts) {
  let priceFeedConsumer;
  let oraclePriceFeed;
  
  beforeEach(async() => {
    [owner, alice, bob ] = accounts;
    priceFeedConsumer = await PriceFeedConsumer.deployed();
    oraclePriceFeed = '0x5f4eC3Df9cbd43714FE2740f5E3616155c5b8419';
  });

  describe("deployment", () => {
    it("deploys successfully", async() => {
      assert(priceFeedConsumer,"Price Feed Consumer contract deployed successfully");
    });
  });

  describe("price data", () => {
    it("should fetch the latest ETH/USD price from onchain price feed oracle", async() => {
      const latestETHPrice = await priceFeedConsumer.getEthPrice();
    });
  });
});
