const { BigNumber } = require('ethers');
const hre = require('hardhat');

async function main() {
  const NappyToken = await hre.ethers.getContractFactory('NappyToken');
  const totalSupply = BigNumber.from(10000000);
  const nappyToken = await NappyToken.deploy(totalSupply);
  nappyTokenAddress = nappyToken.address;

  await nappyToken.deployed();

  console.log('NappyToken deployed to:', nappyToken.address);

  const Vesting = await hre.ethers.getContractFactory('Vesting');
  const vesting = await Vesting.deploy(nappyTokenAddress);

  await vesting.deployed();

  console.log('Vesting deployed to:', vesting.address);
}

main()
  .then(() => process.exit(0))
  .catch((error) => {
    console.error(error);
    process.exit(1);
  });
