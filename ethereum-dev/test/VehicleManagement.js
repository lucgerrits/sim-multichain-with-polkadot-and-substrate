const { expect } = require("chai");
const { ethers } = require("hardhat");

describe("VehicleManagement", function () {
  let admin, factory, otherAccount;
  let vehicleManagement;

  beforeEach(async function () {
    // Get the signers
    [admin, factory, otherAccount] = await ethers.getSigners();
    // console.log("Admin address:", admin.address);
    // console.log("Factory address:", factory.address);
    // console.log("Other account address:", otherAccount.address);
    // Deploy the contract
    vehicleManagement = await hre.ethers.deployContract("VehicleManagement", []);
    await vehicleManagement.waitForDeployment();
  });

  describe("Deployment", function () {
    it("Should set the right admin", async function () {
      expect(await vehicleManagement.admin()).to.equal(admin.address);
    });
  });

  describe("Factories", function () {
    it("Should let the admin create a factory", async function () {
      await vehicleManagement.create_factory(factory.address);
      const storedFactoryBlock = await vehicleManagement.factories(factory.address);
      expect(storedFactoryBlock).to.be.above(0);
    });

    it("Should not let a non-admin create a factory", async function () {
      await expect(vehicleManagement.connect(otherAccount).create_factory(otherAccount.address)).to.be.revertedWith("Only admin can perform this action.");
    });
  });

  describe("Vehicles", function () {
    beforeEach(async function () {
      // First create a factory
      await vehicleManagement.create_factory(factory.address);
    });

    it("Should let factories create a vehicle", async function () {
      await vehicleManagement.connect(factory).create_vehicle(ethers.ZeroAddress);
      const vehicle = await vehicleManagement.vehicles(ethers.ZeroAddress);
      expect(vehicle.factoryId).to.equal(factory.address);
    });

    it("Should not let non-factories create a vehicle", async function () {
      await expect(vehicleManagement.connect(otherAccount).create_vehicle(ethers.ZeroAddress)).to.be.revertedWith("Only factories can create vehicles.");
    });
  });

  describe("Accidents", function () {
    it("Should allow reporting an accident for a registered and initialized vehicle", async function () {
      let accidentCount = await vehicleManagement.getAccidentCount(otherAccount.address);
      expect(accidentCount).to.equal(0);

      // Setup a factory and vehicle
      await vehicleManagement.create_factory(factory.address);
      await vehicleManagement.connect(factory).create_vehicle(otherAccount.address);
      await vehicleManagement.connect(factory).init_vehicle(otherAccount.address);

      // Report an accident
      const dataHash = ethers.encodeBytes32String("Hello world!");
      await vehicleManagement.connect(factory).report_accident(otherAccount.address, dataHash);

      accidentCount = await vehicleManagement.getAccidentCount(otherAccount.address);
      expect(accidentCount).to.equal(1);
    });
  });
  describe("Admin", function () {
    it("Should allow the admin to change the admin", async function () {
      await vehicleManagement.connect(admin).changeAdmin(otherAccount.address);
      expect(await vehicleManagement.admin()).to.equal(otherAccount.address);
    }
    );
    it("Should not allow a non-admin to change the admin", async function () {
      await expect(vehicleManagement.connect(otherAccount).changeAdmin(otherAccount.address)).to.be.revertedWith("Only admin can perform this action.");
    }
    );
  });
});
