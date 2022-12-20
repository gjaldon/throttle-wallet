import { time, loadFixture } from "@nomicfoundation/hardhat-network-helpers";
import { anyValue } from "@nomicfoundation/hardhat-chai-matchers/withArgs";
import { expect } from "chai";
import { ethers } from "hardhat";

describe("ThrottleWallet", function () {
  describe("spend", () => {
    it("refills spending limit", async () => {
      const [bob, dan] = await ethers.getSigners();

      const ERC20Factory = await ethers.getContractFactory("ERC20Mock");
      const token = await ERC20Factory.deploy("Test", "TST");

      const ThrottleWalletFactory = await ethers.getContractFactory(
        "ThrottleWallet"
      );
      const throttleWallet = await ThrottleWalletFactory.deploy(
        token.address,
        20_000,
        1_000
      );

      await token.mint(bob.address, 100_000);
      await token.approve(throttleWallet.address, 50_000);
      await throttleWallet.deposit(bob.address, 50_000);

      expect(await throttleWallet.balances(bob.address)).to.eq(50_000);

      await throttleWallet.spend(dan.address, 20_000);
      await expect(
        throttleWallet.spend(dan.address, 20_000)
      ).to.be.revertedWith("lacking limit");
    });
  });
});
