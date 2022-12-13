import { time, loadFixture } from "@nomicfoundation/hardhat-network-helpers";
import { anyValue } from "@nomicfoundation/hardhat-chai-matchers/withArgs";
import { expect } from "chai";
import { ethers } from "hardhat";

describe("Equations", function () {
  // We define a fixture to reuse the same setup in every test.
  // We use loadFixture to run this setup once, snapshot that state,
  // and reset Hardhat Network to that snapshot in every test.
  // async function deployOneYearLockFixture() {
  //   const ONE_YEAR_IN_SECS = 365 * 24 * 60 * 60;
  //   const ONE_GWEI = 1_000_000_000;

  //   const lockedAmount = ONE_GWEI;
  //   const unlockTime = (await time.latest()) + ONE_YEAR_IN_SECS;

  //   // Contracts are deployed using the first signer/account by default
  //   const [owner, otherAccount] = await ethers.getSigners();

  //   const Lock = await ethers.getContractFactory("Lock");
  //   const lock = await Lock.deploy(unlockTime, { value: lockedAmount });

  //   return { lock, unlockTime, lockedAmount, owner, otherAccount };
  // }

    async function setup(){
        const [owner, otherAccount] = await ethers.getSigners();

        const Equations = await ethers.getContractFactory("Equations");
        const eq = await Equations.deploy(true);

        return { eq, owner, otherAccount};
    }

    describe("Deployment", function() {
        it("Should set the right deployed status", async function () {
        const { eq } = await loadFixture(setup);

        expect(await eq.deployedStatus()).to.equal(true);
        });
    });

    describe("Number of Endorcements", function() {
        it("Value return should be accurate", async function () {
        const { eq } = await loadFixture(setup);

        // value is in basis points, ex 1000 = 10% - 0.1
        const penalty = 10;
        const maxEndorcements = 100;
        const endorcementsMade = 500;

        const numOfEndorcements = await eq.numberOfEndorcements(penalty, maxEndorcements, endorcementsMade);
        console.log("num of End", numOfEndorcements);
    });
})



});
