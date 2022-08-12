import { assert, expect } from "chai";
import { BigNumber } from "ethers";
import { parseEther } from "ethers/lib/utils";
import { parse } from "path";

export const shouldDeposit = (): void => {
  //   // to silent warning for duplicate definition of Transfer event
  //   ethers.utils.Logger.setLogLevel(ethers.utils.Logger.levels.OFF);

  context(`#deposit`, async function () {
    it("should update balance mapping properly", async function () {
      const amount = parseEther('1');
      // previous amount of user
      const preDepositOfUser: BigNumber = (await this.staking.functions.s_balances(this.signers.alice.address))[0];
      await this.staking.connect(this.signers.alice).functions.deposit(amount);
      // get users new deposit
      const newDepositOfUser = (await this.staking.functions.s_balances(this.signers.alice.address))[0];
      assert(newDepositOfUser.toBigInt() === preDepositOfUser.add(amount).toBigInt(), "New deposit value of user should be old plus amount");
    });

    it("should revert with TransferFailed Error ", async function () {
      //tell our mock contract that transferFrom function should return false
      await this.mocks.mockToken.mock.transferFrom.returns(false);
      const amount: BigNumber = parseEther("1");
      await expect(this.staking.connect(this.signers.alice).deposit(
        amount
      )).to.be.revertedWith('TransferFailed')
    })
  });
};
