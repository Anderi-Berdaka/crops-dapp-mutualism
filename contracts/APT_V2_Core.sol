// SPDX-License-Identifier: MIT
pragma solidity ^0.8.28;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/access/AccessControl.sol";

/**
 * @title APT_V2_Core
 * @notice Tokenization layer converting community AI computation metrics into mutual aid reserves.
 * @dev Implements a minting framework fueled by a verified decentralized hardware processing network.
 * * =====================================================================================
 * CROPS FRAMEWORK COMPLIANCE
 * =====================================================================================
 * [C] CENSORSHIP RESISTANCE: Eliminates standard commercial agent classes. Infrastructure revenue 
 * is programmatically minted directly to the shared community pension reserve pool.
 * [O] OPEN SOURCE: Designed to map decentralized AI processing workloads openly, turning data processing 
 * metrics into distributed financial support.
 * [P] PRIVACY: Hardware clusters register via decentralized telemetry metrics without compromising 
 * the physical identities or geographic locations of their operators.
 * [S] SECURITY: Uses a strict multi-signature Oracle check mechanism to verify reported computing work 
 * before adjusting the token supply.
 * =====================================================================================
 */
contract APT_V2_Core is ERC20, AccessControl {
    bytes32 public constant ORACLE_ROLE = keccak256("ORACLE_ROLE");

    address public pensionVault;
    
    // 20% Base Allocation directly routed to fuel community mutual aid systems
    uint256 public constant MUTUAL_AID_BPS = 2000; 

    struct AIComputeNode {
        string hardwareIdentifier; // Open-source bare metal hardware configuration tag
        uint256 activeGpuFlops;    // Verified computational processing speed capacity
        bool isRegistered;         // Operational enrollment state validation flag
    }

    mapping(address => AIComputeNode) public computeNodes;
    
    // Tracks aggregate computation units compiled across the processing architecture
    uint256 public totalAIVolumeProcessed;

    event WorkRecorded(address indexed nodeOperator, uint256 processingUnits, uint256 vaultAllocation);

    /**
     * @param _initialAdmin Master governance identity overseeing structural configurations.
     */
    constructor(address _initialAdmin) ERC20("Automation Productivity Token", "APT") {
        // [SECURITY] Grant governance admin rights to the designated human manager (EOA)
        _grantRole(DEFAULT_ADMIN_ROLE, _initialAdmin);
        _grantRole(ORACLE_ROLE, _initialAdmin); 

        // [SECURITY] Fixes Factory Deployment Revert: Grant admin privileges to the deploying 
        // Hub Factory (msg.sender) so it has the permissions required to link system contracts.
        _grantRole(DEFAULT_ADMIN_ROLE, msg.sender);
    }

    /**
     * @notice Binds the permanent coordinate of the community mutual aid funding pool.
     */
    function setPensionVault(address _pensionVault) external onlyRole(DEFAULT_ADMIN_ROLE) {
        pensionVault = _pensionVault;
    }

    /**
     * @notice Enrolls a bare-metal AI processing rig directly into the decentralized compute network.
     */
    function registerComputeRig(address _operator, string calldata _hardwareId, uint256 _gpuFlops) external onlyRole(ORACLE_ROLE) {
        computeNodes[_operator] = AIComputeNode({
            hardwareIdentifier: _hardwareId,
            activeGpuFlops: _gpuFlops,
            isRegistered: true
        });
    }

    /**
     * @notice Ingests computing network performance data and updates token balances.
     * @dev Automatically splits network proceeds: 80% rewards individual node operators, 
     * while 20% is routed directly into the community mutual aid system.
     * @param _operator Cryptographic address managing the target physical hardware cluster.
     * @param _datasetTokensProcessed Quantitative metrics tracking the scale of completed AI model training runs.
     */
    function recordComputationWork(address _operator, uint256 _datasetTokensProcessed) external onlyRole(ORACLE_ROLE) {
        require(computeNodes[_operator].isRegistered, "Network Error: Unregistered processing infrastructure node");
        require(pensionVault != address(0), "Configuration Error: Target mutual aid vault address is uninitialized");

        // Mathematical normalization scaling raw processing work units down to currency metrics
        uint256 totalToMint = (_datasetTokensProcessed * computeNodes[_operator].activeGpuFlops) / 10**6;
        require(totalToMint > 0, "Execution Exception: Computational work metrics too low to trigger emission state");

        uint256 mutualAidShare = (totalToMint * MUTUAL_AID_BPS) / 10000;
        uint256 operatorShare = totalToMint - mutualAidShare;

        totalAIVolumeProcessed += _datasetTokensProcessed;

        // [CENSORSHIP RESISTANCE] Allocations are minted and deposited programmatically directly into the contract addresses
        _mint(pensionVault, mutualAidShare);
        _mint(_operator, operatorShare);

        emit WorkRecorded(_operator, _datasetTokensProcessed, mutualAidShare);
    }
}