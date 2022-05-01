require("hardhat-deploy");
require("@nomiclabs/hardhat-waffle");
require("dotenv").config();
/**
 * @type import('hardhat/config').HardhatUserConfig
 */
module.exports = {
  solidity: "0.8.7",
  networks: {
    hardhat: {
      chainId: 31337,
    },
    // rinkeby: {
    //   chainId: 4,
    //   url: process.env.RINKBY_RPC_URL,
    //   accounts: [process.env.PRIVATE_KEY],
    // },
  },
  namedAccounts: {
    deployer: {
      default: 0,
    },
  },
};
