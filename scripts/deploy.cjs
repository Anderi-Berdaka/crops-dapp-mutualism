const { ethers } = require("hardhat");

async function main() {
  console.log("=====================================================");
  console.log("Initializing APT Plural System Deployment Suite...");
  console.log("=====================================================");

  // Define constructor configurations for the Hub Factory
  const ORACLE_QUORUM = 1; // 1-of-1 validation scheme for testing deployment setup

  // 1. Get the Hub Contract Factory
  const APTProtocolHub = await ethers.getContractFactory("APT_Protocol_Hub");
  console.log("Deploying APT_Protocol_Hub Factory...");

  // 2. Execute deployment transaction
  const hub = await APTProtocolHub.deploy(ORACLE_QUORUM);
  await hub.waitForDeployment();
  
  const hubAddress = await hub.getAddress();
  console.log(`\n✔ APT_Protocol_Hub successfully deployed to: ${hubAddress}`);

  // 3. Query the Hub to retrieve dynamically generated child addresses
  console.log("\nQuerying internal registry maps for child coordinates...");
  
  const soulRegistryAddress = await hub.soulRegistry();
  const tokenCoreAddress = await hub.tokenCore();
  const networkOracleAddress = await hub.networkOracle();
  const vestingVaultAddress = await hub.vestingVault();

  console.log("-----------------------------------------------------");
  console.log(`🟢 APT_SoulRegistry: ${soulRegistryAddress}`);
  console.log(`🟢 APT_V2_Core (Token):   ${tokenCoreAddress}`);
  console.log(`🟢 APT_Oracle:        ${networkOracleAddress}`);
  console.log(`🟢 APT_VestingVault:  ${vestingVaultAddress}`);
  console.log("-----------------------------------------------------");
  
  console.log("\nDeployment sequence complete. Keep these addresses saved for verification!");
}

main()
  .then(() => process.exit(0))
  .catch((error) => {
    console.error(error);
    process.exit(1);
  });