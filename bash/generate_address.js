const ethers = require("ethers");

function generateEthAddress(privateKey) {
  const wallet = new ethers.Wallet(privateKey);
  console.log(`Ethereum Address: ${wallet.address}`);
}

const privateKey = process.argv[2];
generateEthAddress(privateKey);
