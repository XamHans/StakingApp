import { assert, expect } from "chai";
import { BigNumber } from "ethers";
import { parseEther } from "ethers/lib/utils";
import { parse } from "path";

export const shouldWithdrawl = (): void => {
  //   // to silent warning for duplicate definition of Transfer event
  //   ethers.utils.Logger.setLogLevel(ethers.utils.Logger.levels.OFF);

  context(`#withdrawl`, async function () {
    it("should update balance mapping properly", async function () {
      const amount = parseEther('1');
      // previous amount of user
      await this.staking.connect(this.signers.alice).functions.stake(amount);


      const beforeWithdrawlBalance: BigNumber = 
      (await this.staking.functions.s_balances(this.signers.alice.address))[0];
      
      await this.staking.connect(this.signers.alice).functions.withdrawl(amount);
      console.log('beforeWithdrawlBalance ', beforeWithdrawlBalance)
      // get users new stake
      const afterWithdrawlBalance = (await this.staking.functions.s_balances(this.signers.alice.address))[0];
      console.log('afterWithdrawlBalance ', afterWithdrawlBalance)

      assert(beforeWithdrawlBalance.sub(amount).toBigInt() === afterWithdrawlBalance.toBigInt(), "New stake value of user should be old minus amount");
    });

    it("should revert with TransferFailed Error ", async function () {
      //tell our mock contract that transferFrom function should return false
      await this.mocks.mockToken.mock.transferFrom.returns(false);
      const amount: BigNumber = parseEther("1");
      await expect(this.staking.connect(this.signers.alice).withdrawl(
        amount
      )).to.be.revertedWith('TransferFailed')
    })

    it("should emit WithdrawlEvent event", async function() {
      const amount = parseEther("1")
      await expect(this.staking.connect(this.signers.alice).withdrawl(amount))
        .to.emit(this.staking, "WithdrawlEvent")
        .withArgs(this.signers.alice.address, this.mocks.mockToken.address, amount)
    }) 
  });
};
