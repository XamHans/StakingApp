import { Fixture, MockContract } from "ethereum-waffle";
import { ContractFactory, Wallet } from "ethers";
import { ethers } from "hardhat";
import { Staking } from "../../typechain/Staking";
import { deployMockToken } from "./mocks";

type UnitStakingFixtureType = {
  staking: Staking;
  mockToken: MockContract;
};

export const unitStakingFixture: Fixture<UnitStakingFixtureType> = async (
  signers: Wallet[]
) => {
  const deployer: Wallet = signers[0];
  const mockToken = await deployMockToken(deployer);

  const stakingFactory: ContractFactory = await ethers.getContractFactory(
    `Staking`
  );

  const staking: Staking = (await stakingFactory
    .connect(deployer)
    .deploy(mockToken.address)) as Staking;

  await staking.deployed();


  return { staking, mockToken };
};
