const { ethers } = require("hardhat");
const {JsonRpcProvider} =require("ethers");

async function main() {
  const tokenAddress = "0x1c620232Fe5Ab700Cc65bBb4Ebdf15aFFe96e1B5"; // Replace with the actual token address
  const rewardRate = 10; // Replace with the desired reward rate in percentage

  const [deployer] = await ethers.getSigners();
  console.log("Deploying contracts with the account:", deployer.address);

  const Staking = await ethers.getContractFactory("Staking");
  const stakingContract = await Staking.deploy(tokenAddress, rewardRate);

  await stakingContract.deployed();

  console.log("Staking contract deployed to:", stakingContract.address);
}

// async function main() {

//   const [deployer] = await ethers.getSigners();
//   console.log("Deploying contracts with the account:", deployer.address);

//   console.log("Account balance:", (await deployer.getBalance()).toString());

//   // Compile the contract using Hardhat
//   const stakingContract = await ethers.getContractFactory("Staking");

//   // Deploy the contract to the local Hardhat network
//   const Staking = await stakingContract.deploy();
//   await Staking.deployed();

//   console.log("Staking contract deployed to:", Staking.address);
// }

main()
  .then(() => process.exit(0))
  .catch((error) => {
    console.error(error);
    process.exit(1);
  });