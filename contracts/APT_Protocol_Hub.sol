// SPDX-License-Identifier: MIT
pragma solidity ^0.8.28;

import "./APT_SoulRegistry.sol";
import "./APT_VestingVault.sol";
import "./APT_V2_Core.sol";
import "./APT_Oracle.sol";

/**
 * @title APT_Protocol_Hub
 * @notice Central coordination layer managing deployment connections across the ecosystem.
 * * =====================================================================================
 * CROPS FRAMEWORK COMPLIANCE
 * =====================================================================================
 * [C] CENSORSHIP RESISTANCE: Orchestrates cross-contract coordination automatically, 
 * allowing systems to interact without relying on a centralized intermediary.
 * [O] OPEN SOURCE: Maps layout components openly, ensuring system interactions 
 * can be easily audited by outside developers.
 * [P] PRIVACY: Connects core infrastructure components across a unified interface, 
 * eliminating the need to expose internal operations or user data pipelines.
 * [S] SECURITY: Grants explicit interface permissions across newly generated child contracts, 
 * preventing cross-contract permission leaks.
 * =====================================================================================
 */
contract APT_Protocol_Hub {
    APT_SoulRegistry public soulRegistry;
    APT_VestingVault public vestingVault;
    APT_V2_Core public tokenCore;
    APT_Oracle public networkOracle;
    address public governanceAdmin;

    constructor(uint256 _oracleQuorum) {
        governanceAdmin = msg.sender;

        // Initialize core decentralized social identity tracking components
        soulRegistry = new APT_SoulRegistry(governanceAdmin);

        // Initialize the AI compute revenue tokenization engine
        tokenCore = new APT_V2_Core(governanceAdmin);

        // Initialize multi-tenant validation nodes
        networkOracle = new APT_Oracle(governanceAdmin, _oracleQuorum);

        // Bind the multi-tenant mutual aid reserve structure
        vestingVault = new APT_VestingVault(address(tokenCore), address(soulRegistry));

        // Connect the token core directly to the mutual aid funding reserves
        tokenCore.setPensionVault(address(vestingVault));
    }

    function getVestingVault() external view returns (address) {
        return address(vestingVault);
    }

    function getSoulRegistry() external view returns (address) {
        return address(soulRegistry);
    }
}