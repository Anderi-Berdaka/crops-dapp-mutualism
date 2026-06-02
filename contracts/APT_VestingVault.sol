// SPDX-License-Identifier: MIT
pragma solidity ^0.8.28;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "./APT_SoulRegistry.sol";

/**
 * @title APT_VestingVault
 * @notice Decentralized asset pool executing automated distribution allocations gated by active social standings.
 * * =====================================================================================
 * CROPS FRAMEWORK COMPLIANCE
 * =====================================================================================
 * [C] CENSORSHIP RESISTANCE: Replaces static single-beneficiary keys with dynamic identity checks. 
 * Any verified community member can interact with this reserve directly; no middleman can freeze claims.
 * [O] OPEN SOURCE: Formulas governing individual claims, time cliffs, and distribution frequencies 
 * are immutable and clearly visible in code.
 * [P] PRIVACY: Distributes funds to valid cryptographic addresses, avoiding the need for tracking 
 * centralized banking routes or physical credentials.
 * [S] SECURITY: Cross-contract verification prevents unauthorized addresses from draining the reserves.
 * =====================================================================================
 */
contract APT_VestingVault {
    IERC20 public aptToken;
    APT_SoulRegistry public soulRegistry;

    uint256 public epochDuration = 30 days;
    uint256 public baseDistributionRate = 100 * 10**18; // Base asset allowance per member per epoch

    // Maps member address to the last timestamp an alignment claim was successfully executed
    mapping(address => uint256) public lastClaimTimestamp;
    uint256 public totalReleasedFunds;

    event AidDistributed(address indexed beneficiary, uint256 amount, uint256 timestamp);

    /**
     * @param _aptToken Contract coordinate pointing to the underlying network utility currency ledger.
     * @param _soulRegistry Coordinate mapping directly to the active identity verification system.
     */
    constructor(address _aptToken, address _soulRegistry) {
        aptToken = IERC20(_aptToken);
        soulRegistry = APT_SoulRegistry(_soulRegistry);
    }

    /**
     * @notice Displays the aggregate reserve capital currently secured inside the mutual aid pool.
     */
    function getTotalReserves() public view returns (uint256) {
        return aptToken.balanceOf(address(this)) + totalReleasedFunds;
    }

    /**
     * @notice Evaluates individual allocations by processing current identity parameters.
     * @dev Implements dynamic tier weighting linked directly to individual roles:
     * - Tier 2 (Member): Base Rate Multiplier (1x)
     * - Tier 3 (Grid Maintainer): Operational Maintenance Premium (1.5x)
     * - Tier 4 (Community Elder): Governance Coordination Premium (2x)
     */
    function calculateEntitlement(address _member) public view returns (uint256) {
        uint8 tier = uint8(soulRegistry.getSoulTier(_member));
        
        // [SECURITY] Immediate restriction: Unverified Souls (0) and Newcomers (1) receive zero allocations
        if (tier < 2) return 0;
        if (block.timestamp < lastClaimTimestamp[_member] + epochDuration && lastClaimTimestamp[_member] != 0) return 0;

        if (tier == 2) return baseDistributionRate;
        if (tier == 3) return (baseDistributionRate * 15) / 10;
        if (tier == 4) return baseDistributionRate * 2;
        
        return 0;
    }

    /**
     * @notice Triggers an explicit distribution withdrawal directly from the shared pool.
     * @dev Enforces multi-tenant programmatic security by verifying active identity registry indices.
     */
    function release() external {
        uint8 tier = uint8(soulRegistry.getSoulTier(msg.sender));
        // [CENSORSHIP RESISTANCE] Valid claims are executed purely on programmatic compliance, bypassing manual approval
        require(tier >= 2, "Access Denied: Insufficient identity tier for mutual aid distributions");
        require(block.timestamp >= lastClaimTimestamp[msg.sender] + epochDuration, "Distribution Lock: Limit one distribution per epoch cycle");

        uint256 payout = calculateEntitlement(msg.sender);
        require(payout > 0, "Calculation Error: Evaluated entitlement yields zero balance");
        require(aptToken.balanceOf(address(this)) >= payout, "Liquidity Constraint: Insufficient vault reserves");

        lastClaimTimestamp[msg.sender] = block.timestamp;
        totalReleasedFunds += payout;

        require(aptToken.transfer(msg.sender, payout), "Token Execution Failure: Outgoing transfer failed");
        emit AidDistributed(msg.sender, payout, block.timestamp);
    }
}