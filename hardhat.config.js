require("@nomicfoundation/hardhat-toolbox");
require("dotenv").config();
require("./tasks");
/** @type import('hardhat/config').HardhatUserConfig */
module.exports = {
  solidity:
  {
    compilers: [{
      version: "0.8.19",
      settings: {
        optimizer: {
          enabled: true,
          runs: 1,
        },
      },
    },
    {
      version: "0.4.11",
      settings: {
        optimizer: {
          enabled: true,
          runs: 1,
        },
      },
    },
    {
      version: "0.4.24",
      settings: {
        optimizer: {
          enabled: true,
          runs: 1,
        },
      },
    }
    ]
  },
  defaultNetwork: "rippleEvmSidechain",
  networks: {
    mumbai: {
      url: process.env.ALCHEMY_POLYGON_URL,
      accounts: [process.env.ACCOUNT_PRIVATE_KEY],
      chainId: 80001,
    },
    rippleEvmSidechain: {
      url: process.env.RIPPLE_EVM_SIDECHAIN_RPC,
      accounts: [process.env.ACCOUNT_PRIVATE_KEY],
      chainId: 1440002,
    }
  },
  etherscan: {
    apiKey: {
      polygonMumbai: process.env.POLYGONSCAN_API_KEY,
      rippleEvmSidechain: "abc"
    },
    customChains: [
      {
        network: "rippleEvmSidechain",
        chainId: 1440002,
        urls: {
          apiURL: "https://evm-sidechain.xrpl.org/api",
          browserURL: "https://evm-sidechain.xrpl.org",
        },
      }
    ]
  }
};
