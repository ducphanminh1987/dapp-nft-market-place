const { ethers } = require("hardhat");

async function main() {
  //   const [owner] = await ethers.getSigners();

  const NFTMarketPlace = await ethers.getContractFactory("NFTMarketPlace");
  const nftMarketPlace = await NFTMarketPlace.deploy();
  await nftMarketPlace.deployed();

  console.log("deployed to NFTMarketPlace", nftMarketPlace.address);
}

main()
  .then(() => process.exit(1))
  .catch((error) => {
    console.error(error);
    process.exit(0);
  });
