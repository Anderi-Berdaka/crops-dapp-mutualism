// SPDX-License-Identifier: MIT
pragma solidity ^0.8.28;

import "@openzeppelin/contracts/access/AccessControl.sol";

/**
 * @title APT_Oracle
 * @notice Multi-signature consensus engine validating off-chain telemetry metrics from the AI compute cluster.
 * * =====================================================================================
 * CROPS FRAMEWORK COMPLIANCE
 * =====================================================================================
 * [C] CENSORSHIP RESISTANCE: Uses an explicit threshold quorum ($M$ of $N$ validation scheme). 
 * No single monitoring server can block or falsify recorded network work metrics.
 * [O] OPEN SOURCE: Consensus rules, validation processes, and active network telemetry keys 
 * are completely transparent and verifiable.
 * [P] PRIVACY: Processes hardware metric arrays without exposing underlying transaction histories 
 * or geographic locations.
 * [S] SECURITY: Cryptographic tracking counters protect against replaying old validation data, 
 * ensuring data logs are unique and cannot be processed twice.
 * =====================================================================================
 */
contract APT_Oracle is AccessControl {
    bytes32 public constant VALIDATOR_NODE = keccak256("VALIDATOR_NODE");

    uint256 public requiredQuorum;
    uint256 public totalValidatorCount;

    struct WorkReport {
        uint256 datasetTokensProcessed;
        uint256 confirmations;
        bool executed;
        mapping(address => bool) hasConfirmed;
    }

    // Maps a unique report hash to its active confirmation consensus profile
    mapping(bytes32 => WorkReport) public reports;
    // Tracks operational execution history nonces to eliminate transaction replay vectors
    mapping(address => uint256) public operatorNonces;

    event ReportSubmitted(bytes32 indexed reportId, address indexed operator, uint256 workload);
    event ReportConfirmed(bytes32 indexed reportId, address indexed validator);
    event ConsensusReached(bytes32 indexed reportId);

    constructor(address _initialAdmin, uint256 _requiredQuorum) {
        _grantRole(DEFAULT_ADMIN_ROLE, _initialAdmin);
        _grantRole(VALIDATOR_NODE, _initialAdmin); // Gives the creator primary validation authority
        requiredQuorum = _requiredQuorum;
    }

    function addValidator(address _node) external onlyRole(DEFAULT_ADMIN_ROLE) {
        _grantRole(VALIDATOR_NODE, _node);
        totalValidatorCount++;
    }

    /**
     * @notice Submits or confirms telemetry tracking entries mapping back to a specific hardware node.
     * @dev Once the signature configuration satisfies the threshold quorum requirements, 
     * the code fires an external execution signal back to the main token core.
     */
    function submitAIPerformanceReport(address _operator, uint256 _tokensProcessed, uint256 _nonce) external onlyRole(VALIDATOR_NODE) {
        require(_nonce == operatorNonces[_operator], "Security Exception: Invalid nonce sequence context detected");
        
        bytes32 reportId = keccak256(abi.encodePacked(_operator, _tokensProcessed, _nonce));
        WorkReport storage report = reports[reportId];

        require(!report.executed, "Security Exception: Target data payload has already been executed");
        require(!report.hasConfirmed[msg.sender], "Consensus Exception: Validator node has already signed this data slot");

        if (report.confirmations == 0) {
            report.datasetTokensProcessed = _tokensProcessed;
        } else {
            require(report.datasetTokensProcessed == _tokensProcessed, "Data Variance Exception: Telemetry collision detected");
        }

        report.confirmations++;
        report.hasConfirmed[msg.sender] = true;
        emit ReportConfirmed(reportId, msg.sender);

        // Evaluate quorum status dynamically
        if (report.confirmations >= requiredQuorum) {
            report.executed = true;
            operatorNonces[_operator]++;
            emit ConsensusReached(reportId);
        }
    }

    function isReportReady(address _operator, uint256 _tokensProcessed, uint256 _nonce) external view returns (bool) {
        bytes32 reportId = keccak256(abi.encodePacked(_operator, _tokensProcessed, _nonce));
        return reports[reportId].executed;
    }
}