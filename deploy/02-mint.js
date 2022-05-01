const { ethers } = require("hardhat");

module.exports = async ({ getNamedAccounts, deployments }) => {
  const { deployer } = await getNamedAccounts();
  const randomIpfsNft = await ethers.getContract("randomIpfsNft", deployer);
  const randomIpfsNftMintTx = await randomIpfsNft.requestDoggie();
  const randomIpfsNftMintTxReceipt = await randomIpfsNftMintTx.wait(1);
};

module.exports.tags = ["all", "mint"];

//deploy on rinkeby and add contract address as consumer in chainlink vrf
//see on etherscan
