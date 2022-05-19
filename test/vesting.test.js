const { expect } = require('chai');
const { BigNumber } = require('ethers');
const { ethers } = require('hardhat');

describe('Vesting', function () {
  let NappyToken;
  let nappyToken;
  let Vesting;
  let vesting;
  let addr1;
  let addr2;
  let addr3;
  let addr4;
  let owner;
  let creator;

  beforeEach(async () => {
    [owner, creator, addr1, addr2, addr3] = await ethers.getSigners();
    NappyToken = await ethers.getContractFactory('NappyToken');
    const totalSupply = BigNumber.from(10000000);
    nappyToken = await NappyToken.deploy(totalSupply);
    await nappyToken.deployed();
    nappyTokenAddress = nappyToken.address;

    // For Vesting Contract

    Vesting = await hre.ethers.getContractFactory('Vesting');
    vesting = await Vesting.deploy(nappyTokenAddress);
    await vesting.deployed();
    vestingAddress = vesting.address;

    await nappyToken.transfer(
      vestingAddress,
      nappyToken.balanceOf(owner.address)
    );

    await vesting.connect(owner).addBeneficiary(addr1.address, 0);
    await vesting.connect(owner).addBeneficiary(addr2.address, 1);
    await vesting.connect(owner).addBeneficiary(addr3.address, 2);
  });

  it('Should start the vesting ', async () => {
    await vesting.startVesting(2 * 2629743, 22 * 2629743);

    expect(await vesting.vestingStarted()).to.equal(true);
  });

  it('Should not claim tokens in cliff period ', async () => {
    await vesting.startVesting(2 * 2629743, 22 * 2629743);

    expect(vesting.connect(addr1).claimToken()).to.be.revertedWith();
  });

  it('Should claim tokens after cliff period ', async () => {
    await vesting.startVesting(2 * 2629743, 22 * 2629743);

    await ethers.provider.send('evm_increaseTime', [
      2 * 2629743 + 22 * 2629743,
    ]);
    const balanceBefore = await nappyToken
      .connect(addr1)
      .balanceOf(addr1.address);

    await vesting.connect(addr1).claimToken();

    const balanceAfter = await nappyToken
      .connect(addr1)
      .balanceOf(addr1.address);

    expect(balanceBefore).to.be.not.equal(balanceAfter);
  });

  it('Should claim tokens after cliff period ', async () => {
    await vesting.startVesting(2 * 2629743, 22 * 2629743);

    await ethers.provider.send('evm_increaseTime', [
      2 * 2629743 + 22 * 2629743,
    ]);
    const balanceBefore = await nappyToken
      .connect(addr1)
      .balanceOf(addr1.address);

    await vesting.connect(addr1).claimToken();

    const balanceAfter = await nappyToken
      .connect(addr1)
      .balanceOf(addr1.address);

    expect(balanceBefore).to.be.not.equal(balanceAfter);
  });
});
