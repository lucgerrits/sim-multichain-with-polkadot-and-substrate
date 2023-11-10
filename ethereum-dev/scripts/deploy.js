const hre = require("hardhat");

async function main() {
  const vehicleManagement = await hre.ethers.deployContract("VehicleManagement", []);

  await vehicleManagement.waitForDeployment();
  console.log(vehicleManagement)
  console.log(
    `VehicleManagement deployed to: ${vehicleManagement.target}`
  );
}

main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});
