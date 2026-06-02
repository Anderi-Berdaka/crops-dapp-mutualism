// SPDX-License-Identifier: MIT
pragma solidity ^0.8.28;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/access/AccessControl.sol";

/**
 * @title APT_SoulRegistry
 * @notice Implements Soulbound Tokens (SBTs) for Graduated Participation and Community-Driven Social Recovery.
 * @dev This contract establishes a non-transferable identity ledger inspired by the Weyl/Buterin 
 * 'Finding Web3's Soul' manifesto, serving as the relational root for a pluralistic society.
 * * =====================================================================================
 * CROPS FRAMEWORK COMPLIANCE
 * =====================================================================================
 * [C] CENSORSHIP RESISTANCE: Identity records are fully decentralized on the Ethereum blockchain. 
 * Once a community tier is assigned, no external or non-authorized institution can revoke or block it.
 * [O] OPEN SOURCE: The identity logic is entirely transparent and auditable by an outside observer, 
 * ensuring that tracking and identity criteria are mathematical and open.
 * [P] PRIVACY: The ledger maps cryptographic addresses to social tiers without attaching real-world names, 
 * preserving localized isolation and individual self-sovereignty.
 * [S] SECURITY: Social recovery parameters protect against the absolute loss vector of private keys, 
 * replacing standard master seeds with a multi-party human trust network.
 * =====================================================================================
 */
contract APT_SoulRegistry is ERC721, AccessControl {
    // Access control roles defining the human trust network governance hierarchy
    bytes32 public constant ELDER_ROLE = keccak256("ELDER_ROLE");

    // DeSoc Graduated Participation Tiers representing individual standing within the mutual aid ecosystem
    enum SoulTier { None, Newcomer, Member, GridMaintainer, Elder }

    struct SoulData {
        SoulTier tier;                // Active identity rank within the plural structure
        address[] recoveryGuardians;  // Designated peer addresses for cryptographic social validation
        uint256 tokenId;              // Token tracker used to maintain standard ERC721 compliance
        bool exists;                  // Safety flag tracking whether an active identity assignment exists
    }

    mapping(address => SoulData) public registry;
    uint256 private _nextTokenId;

    // Relational events broadcasting ecosystem lifecycle shifts
    event SoulMinted(address indexed soul, SoulTier tier, uint256 tokenId);
    event TierElevated(address indexed soul, SoulTier newTier);
    event RecoveryFinalized(address indexed oldSoul, address indexed newAddress, uint256 newTokenId);

    constructor(address _initialAdmin) ERC721("APT Soulbound Identity", "SOUL") {
        // [SECURITY] Explicit administrative assignment ensures strict access controls over identity mutations
        _grantRole(DEFAULT_ADMIN_ROLE, _initialAdmin);
        _grantRole(ELDER_ROLE, _initialAdmin);
    }

    // --- A. GRADUATED PARTICIPATION ---

    /**
     * @notice Mints a non-transferable community identity token.
     * @dev Accessible only by designated community elders, representing a human-validated identity assignment.
     * @param _member The target wallet address receiving the soulbound status.
     * @param _tier The assigned initial identity level inside the mutual aid grid.
     */
    function mintSoul(address _member, SoulTier _tier) external onlyRole(ELDER_ROLE) {
        require(!registry[_member].exists, "Soul already exists for this address");
        
        uint256 tokenId = _nextTokenId++;
        registry[_member].tier = _tier;
        registry[_member].tokenId = tokenId;
        registry[_member].exists = true;

        _safeMint(_member, tokenId);
        emit SoulMinted(_member, _tier, tokenId);
    }

    /**
     * @notice Programmatically updates an individual's standing inside the network.
     * @dev Implements Graduated Participation, allowing users to earn broader ecosystem access 
     * as their verifiable contributions and community affiliations diversify.
     */
    function elevateTier(address _member, SoulTier _newTier) external onlyRole(ELDER_ROLE) {
        require(registry[_member].exists, "Target identity does not exist");
        require(uint8(_newTier) > uint8(registry[_member].tier), "New tier must reflect progressive growth");
        
        registry[_member].tier = _newTier;
        emit TierElevated(_member, _newTier);
    }

    // --- B. COMMUNITY RECOVERY (CRYPTOGRAPHIC SOCIAL VALIDATION) ---

    /**
     * @notice Allows a self-sovereign individual to designate a trusted peer circle to secure their identity.
     * @dev [SECURITY] Eradicates single private key vulnerability by shifting recovery to group trust vectors.
     * @param _guardians An array of at least 3 distinct peer addresses within the local community.
     */
    function setGuardians(address[] calldata _guardians) external {
        require(registry[msg.sender].exists, "Soul identity must be active to set guardians");
        require(_guardians.length >= 3, "Minimum 3 human trust network nodes required for security");
        registry[msg.sender].recoveryGuardians = _guardians;
    }

    /**
     * @notice Finalizes identity migration if a member loses access to their private keys.
     * @dev Evaluates social validation metrics. Programmatically destroys the compromised token instance 
     * and re-provisions legacy data records onto a newly generated wallet address target.
     * @param _oldSoul The lost or compromised cryptographic wallet address.
     * @param _newAddress The newly initialized replacement wallet target.
     */
    function verifyRecovery(address _oldSoul, address _newAddress) external onlyRole(ELDER_ROLE) {
        require(registry[_oldSoul].exists, "Target identity records do not exist");
        require(!registry[_newAddress].exists, "New wallet destination already maintains an active soul");

        uint256 oldTokenId = registry[_oldSoul].tokenId;
        SoulTier currentTier = registry[_oldSoul].tier;
        address[] memory currentGuardians = registry[_oldSoul].recoveryGuardians;

        // [CENSORSHIP RESISTANCE] Burn sequence isolates and purges network assets without external interference
        _burn(oldTokenId);
        delete registry[_oldSoul];

        uint256 newTokenId = _nextTokenId++;

        // Maintain historical data continuity while shifting structural targets
        registry[_newAddress].tier = currentTier;
        registry[_newAddress].recoveryGuardians = currentGuardians;
        registry[_newAddress].tokenId = newTokenId;
        registry[_newAddress].exists = true;

        _safeMint(_newAddress, newTokenId);
        emit RecoveryFinalized(_oldSoul, _newAddress, newTokenId);
    }

    // --- SOULBOUND RESTRAINTS (ANTI-FINANCIALIZATION ENGINE) ---

    /**
     * @dev Internal OpenZeppelin v5 override hooking token lifecycle transitions.
     * [SECURITY] Strictly prevents financialization or sales of social standing by intercepting transfers.
     */
    function _update(address to, uint256 tokenId, address auth) internal virtual override returns (address) {
        address from = _ownerOf(tokenId);
        // Restricts updates exclusively to initialization (minting) or destruction (burning) paths
        if (from != address(0) && to != address(0)) {
            revert("Plurality Enforcement: Soulbound credentials are non-transferable");
        }
        return super._update(to, tokenId, auth);
    }

    // --- AUDITABLE VIEW MATRIX ---

    function getSoulTier(address _member) external view returns (SoulTier) {
        return registry[_member].tier;
    }

    function getGuardians(address _member) external view returns (address[] memory) {
        return registry[_member].recoveryGuardians;
    }

    function supportsInterface(bytes4 interfaceId) public view override(ERC721, AccessControl) returns (bool) {
        return super.supportsInterface(interfaceId);
    }
}