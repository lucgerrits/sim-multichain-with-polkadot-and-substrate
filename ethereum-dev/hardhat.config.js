require("@nomicfoundation/hardhat-toolbox");
require("@nomicfoundation/hardhat-chai-matchers");
require("@nomicfoundation/hardhat-ethers");
require('solidity-coverage')
require("hardhat-gas-reporter");

/** @type import('hardhat/config').HardhatUserConfig */
const COINMARKETCAP_API_KEY = process.env.COINMARKETCAP_API_KEY;
module.exports = {
  solidity: "0.8.19",
  // add optimization
  settings: {
    optimizer: {
      enabled: true,
      runs: 200
    }
  },
  gasReporter: {
    enabled: true,
    noColors: true,
    // token: "ETH",
    currency: 'EUR',
    coinmarketcap: COINMARKETCAP_API_KEY,
    gasPriceApi: "https://api.etherscan.io/api?module=proxy&action=eth_gasPrice"
    // outputFile: "gas-reporter.txt",
  }
};
