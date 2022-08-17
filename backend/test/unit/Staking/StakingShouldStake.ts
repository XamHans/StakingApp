import { assert, expect } from "chai";
import { BigNumber } from "ethers";
import { parseEther } from "ethers/lib/utils";
import { parse } from "path";

export const shouldStake = (): void => {
  //   // to silent warning for duplicate definition of Transfer event
  //   ethers.utils.Logger.setLogLevel(ethers.utils.Logger.levels.OFF);

  context(`#stake`, async function () {
    it("should update balance mapping properly", async function () {
      const amount = parseEther('1');
      // previous amount of user
      const beforeBalance: BigNumber = (await this.staking.functions.s_balances(this.signers.alice.address))[0];
      await this.staking.connect(this.signers.alice).functions.stake(amount);
      // get users new stake
      const afterBalance = (await this.staking.functions.s_balances(this.signers.alice.address))[0];
      assert(afterBalance.toBigInt() === beforeBalance.add(amount).toBigInt(), "New stake value of user should be old plus amount");
    });

    it("should revert with TransferFailed Error ", async function () {
      //tell our mock contract that transferFrom function should return false
      await this.mocks.mockToken.mock.transferFrom.returns(false);
      const amount: BigNumber = parseEther("1");
      await expect(this.staking.connect(this.signers.alice).stake(
        amount
      )).to.be.revertedWith('TransferFailed')
    })

    it("should emit stake event", async function() {
      const amount = parseEther("1")
      await expect(this.staking.connect(this.signers.alice).stake(amount))
        .to.emit(this.staking, "StakeEvent")
        .withArgs(this.signers.alice.address, this.mocks.mockToken.address, amount)
    }) 
  });
};
