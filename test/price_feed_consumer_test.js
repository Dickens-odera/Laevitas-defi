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
  let duration;

  beforeEach(async() => {
    [owner, alice, bob ] = accounts;
    mockController = await MockController.deployed();
    mockOracle = await MockOracle.deployed();
    priceFeedConsumer = await new PriceFeedConsumer(mockController, mockOracle);
    chainLinkOraclePriceFeed = '0x5f4eC3Df9cbd43714FE2740f5E3616155c5b8419';
    mockUSDC = await MockUSDC.deployed();
    mockWETH = await MockWETH.deployed();
    mockoSQTH = await MockosQueethToken.deployed();
    duration = 1;
  });

  describe("deployment", () => {
    it("deploys successfully", async() => {
      assert(priceFeedConsumer,"Price Feed Consumer contract deployed successfully");
    });
  });

  describe("mocks", () => {
    describe("Mock SQUEETH Controller Tests", async() => {
      it('can enable the contract owner to set the trading period(int)', async () => {
        const result = await mockController.setTransactionPeriod(duration, { from: owner });

        assert(result.receipt.status, true);
        assert.equal(result.logs[0].args.user, owner);
        assert.equal(result.logs[0].args.newTxPeriod, duration);
        assert.equal(result.logs[0].args.date, new Date().getTime());
      });

      it('can get the total index prices(ETH^2)', async () => {
        const totalIndexPrices = await mockController.totalIndexPrices();

        assert.equal(totalIndexPrices, 0);
      });

      it('can enable the contract owner to set the index price(ETH^2) for a prticular trading duration', async () => {
        const currentIndexPrice = await mockController.indexByDuration(duration);
        const result = await mockController.setIndex(duration, { from: owner });

        assert.equal(currentIndexPrice, 1); //confirm that the indexprice was increased by 1

        //Get the log details of the emitted NewIndex event
        assert(result.receipt.status, true);
        assert.equal(result.logs[0].args.caller, owner);
        assert.equal(result.logs[0].args.date, new Date().getTime());
      });

      it('can fectch the index price(ETH^2) by duration', async () => {
        const durationIndexPrice = await mockController.indexByDuration(duration);

        assert.equal(durationIndexPrice, 1); //confirm that the indexprice was increased by 1
      });

      it('can successfully enable the contract owner to set the normalization mark price(oSQUEETH) price for a particular duration', async() => {
        const result = await mockController.setDenormalizedMark(duration, { from : owner });
        const markPriceByDuration = await mockController.denormalizedMarkPrice(duration);
        const totalMarkPrices = await mockController.totalMarkPrices(); //should be 1 after the increase

        assert(result.receipt.status, true);
        assert.equal(totalMarkPrices, 1);
        assert.equal(markPriceByDuration, 1); //having been increased by 1 upon triggering this function

        //Get the log details of the emitted NewMarkPrice event
        assert(result.receipt.status, true);
        assert.equal(result.logs[0].args.user, owner);
        assert.equal(result.logs[0].args.newMarkprice, 1);
        assert.equal(result.logs[0].args.date, new Date().getTime());
      });

      it('can return the mark price (oSQUEETH)', async() => {

      });

      it('can ssss... ',async() => {

      });
    });

  });

  describe("price data", () => {
    it("should fetch the latest ETH/USD price from onchain price feed oracle", async() => {
      const latestETHPrice = await priceFeedConsumer.getEthPrice();
    });
  });
});
