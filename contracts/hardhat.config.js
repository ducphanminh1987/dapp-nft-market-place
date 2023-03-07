/** @type import('hardhat/config').HardhatUserConfig */

require("@nomicfoundation/hardhat-toolbox");

module.exports = {
  solidity: "0.8.18",
  networks: {
    goerli: {
      url: "https://eth-goerli.g.alchemy.com/v2/qmG3P8zJ-D2KihqrVWy8Frqg9aSIg389",
      accounts: [
        "5b0e77b89722227d8fd989901c520dfa01952d7afb4b82f1318dd26dc9bf1ded",
      ],
    },
  },
};
