const { expect } = require('chai');
const { BigNumber } = require('ethers');
const { ethers } = require('hardhat');

describe('Vesting', function () {
  it('Should start the vesting ', async function () {
    [owner, creator, addr1, addr2, addr3] = await ethers.getSigners();
    const NappyToken = await ethers.getContractFactory('NappyToken');
    const totalSupply = BigNumber.from(10000000);
    const nappyToken = await NappyToken.deploy(totalSupply);
    await nappyToken.deployed();
    nappyTokenAddress = nappyToken.address;

    // For Vesting Contract

    const Vesting = await hre.ethers.getContractFactory('Vesting');
    const vesting = await Vesting.deploy(nappyTokenAddress);
    await vesting.deployed();
    vestingAddress = vesting.address;

    await nappyToken.transfer(
      vestingAddress,
      nappyToken.balanceOf(owner.address)
    );

    await vesting.connect(owner).addBeneficiary(addr1.address, 0);
    await vesting.connect(owner).addBeneficiary(addr2.address, 1);
    await vesting.connect(owner).addBeneficiary(addr3.address, 2);

    await vesting.startVesting(2 * 2629743, 22 * 2629743);

    expect(await vesting.vestingStarted()).to.equal(true);
  });
});
