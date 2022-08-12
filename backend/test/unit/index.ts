import { waffle } from "hardhat";
import { unitStakingFixture } from "../shared/fixtures";
import { Mocks, Signers } from "../shared/types";
import { shouldDeposit } from "./Staking/StakingShouldDeposit";

describe(`Unit tests`, async () => {
  before(async function () {
    const wallets = waffle.provider.getWallets();

    this.signers = {} as Signers;
    this.signers.deployer = wallets[0];
    this.signers.alice = wallets[1];
    this.signers.bob = wallets[2];

    this.loadFixture = waffle.createFixtureLoader(wallets);
  });

  describe(`Staking`, async () => {
    beforeEach(async function () {
      const { staking, mockToken } = await this.loadFixture(unitStakingFixture);

      this.staking = staking;

      this.mocks = {} as Mocks;
      this.mocks.mockToken = mockToken;
    });

    shouldDeposit();
  });
});
