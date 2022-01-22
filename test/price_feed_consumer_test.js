const PriceFeedConsumer = artifacts.require("PriceFeedConsumer");
const MockController = artifacts.require('MockSqueethController');
const MockOracle = artifacts.require('MockSqueethOracle');
const MockUSDC = artifacts.require('MockUSDC');
const MockWETH = artifacts.require('MockWETH');
const MockosQueethToken = artifacts.require('MockoSQUEETH');

const assert = require('assert');

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

    });

  });

  describe("Price Consumer and Oracle Functions", () => {
    it('can set pool price', async() => {
      const poolPrice = 100;
      const result = await mockOracle.setPrice(mockOracle, poolPrice, { from: owner });

      const poolPeriodPrice = await mockOracle.poolPeriodPrice(mockOracle);

      assert(result.receipt.status, true);
      assert.equal(poolPeriodPrice, 200);
    });

    it("can fetch the latest ETH/USDC price from squeeth/vuniswap-3 price pool", async() => {
      const latestETHPrice = await priceFeedConsumer.getSquUniswapPoolEthPrice(mockOracle, mockWETH, mockUSDC, duration ,true);
      const equalOracleEthUsdcPrice = await mockOracle.getTwap(mockOracle, mockWETH, mockUSDC, duration, true);
      console.log("WETH/USDC Pool Price",latestETHPrice);

      assert.equal(latestETHPrice, equalOracleEthUsdcPrice);
    });

    it('can return the mark price (oSQUEETH)', async () => {
      const markPrice = await priceFeedConsumer.getMarkPrice(duration);

      assert.equal(markPrice, 1);
    });

    it('can fetch the current funding rate by duration', async () => {
      const fundingRate = await priceFeedConsumer.getCurrentFundingRate(duration);

      const markPrice = await priceFeedConsumer.getMarkPrice(duration);
      const indexPrice = await priceFeedConsumer.getMarkPrice(duration);
      const position = 1;
      const diff = markPrice - indexPrice;
      const calculatedFundingRate = ((position * diff) * 10 / 100);

      assert.equal(fundingRate, calculatedFundingRate);
    });

  });

  describe("Ownership and Contract Restrictions", () =>{
    it('can only allow the contract owner to set the pool price', async() => {
      const newDuration = 2;
      const result = await mockController.setTransactionPeriod(newDuration, { from: owner });
      try{
        const result = await mockOracle.setPrice(newDuration, { from: alice });
      
      } catch(error){
        assert(error.message.includes("Ownable: caller is not the owner"));
        return;
      }
      assert(false);
    });

    it('can only allow the contract owner to set the pool tick price', async() => {
      try{
        const tickPrice = 100;
        const result = await mockOracle.ssetAverageTick(mockOracle, tickPrice, { from : alice });
      }catch(error){
        assert(error.message.includes("Ownable: caller is not the owner"));
        return;
      }
      assert(false);
    });
  });
});
