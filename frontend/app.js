/**
 * =====================================================================================
 * APT PLURALITY NETWORK SYSTEM - INTEGRATION LAYER (V2-REINFORCED)
 * Driven by standard Web3 asynchronous engine paradigms and Ethers.js v6.
 * =====================================================================================
 * CROPS FRAMEWORK COMPLIANCE DESIGNATION:
 * [C] CENSORSHIP RESISTANCE: Direct cryptographic execution bypassing intermediary layers.
 * [O] OPEN SOURCE: Complete structural logic transparency with educational execution logs.
 * [P] PRIVACY: Sovereign client-side profile computation utilizing abstracted addresses.
 * [S] SECURITY: Two-phase decoupled consensus settlement guarding the system token supply.
 * =====================================================================================
 */

// Core Contract Coordinates (Updated from live Sepolia deployment parameters)
const HUB_ADDRESS = "0x5d49d0fe5b840f2eCdBDaDcaa402F1937B24F684"; 
let REGISTRY_ADDRESS = "0xD06F078929Ffc03a2C7D60639dD5bB9d9B441D03";
let TOKEN_ADDRESS = "0x002194Aa87fB4B93eD69Ec144940d07266566cf7";
let ORACLE_ADDRESS = "0x794023747629d5b2D4A84b0fDC11954E8D7AC7a0";
let VAULT_ADDRESS = "0x676E8f3141b06c7693c4De58aa86Af5988a6dA98";

// Comprehensive Contract Application Binary Interfaces (ABIs)
const HUB_ABI = [
    {
        "inputs": [],
        "name": "getVestingVault",
        "outputs": [{"internalType": "address", "name": "", "type": "address"}],
        "stateMutability": "view",
        "type": "function"
    },
    {
        "inputs": [],
        "name": "getSoulRegistry",
        "outputs": [{"internalType": "address", "name": "", "type": "address"}],
        "stateMutability": "view",
        "type": "function"
    },
    {
        "inputs": [],
        "name": "tokenCore",
        "outputs": [{"internalType": "address", "name": "", "type": "address"}],
        "stateMutability": "view",
        "type": "function"
    },
    {
        "inputs": [],
        "name": "networkOracle",
        "outputs": [{"internalType": "address", "name": "", "type": "address"}],
        "stateMutability": "view",
        "type": "function"
    }
];

const VAULT_ABI = [
    {
        "inputs": [],
        "name": "getTotalReserves",
        "outputs": [{"internalType": "uint256", "name": "", "type": "uint256"}],
        "stateMutability": "view",
        "type": "function"
    },
    {
        "inputs": [{"internalType": "address", "name": "_member", "type": "address"}],
        "name": "calculateEntitlement",
        "outputs": [{"internalType": "uint256", "name": "", "type": "uint256"}],
        "stateMutability": "view",
        "type": "function"
    },
    {
        "inputs": [],
        "name": "release",
        "outputs": [],
        "stateMutability": "nonpayable",
        "type": "function"
    }
];

const REGISTRY_ABI = [
    {
        "inputs": [{"internalType": "address", "name": "_member", "type": "address"}],
        "name": "getSoulTier",
        "outputs": [{"internalType": "uint8", "name": "", "type": "uint8"}],
        "stateMutability": "view",
        "type": "function"
    },
    {
        "inputs": [
            {"internalType": "address", "name": "_account", "type": "address"},
            {"internalType": "uint8", "name": "_tier", "type": "uint8"}
        ],
        "name": "mintSoulProfile",
        "outputs": [],
        "stateMutability": "nonpayable",
        "type": "function"
    },
    {
        "inputs": [{"internalType": "address[]", "name": "_guardians", "type": "address[]"}],
        "name": "setTrustedGuardians",
        "outputs": [],
        "stateMutability": "nonpayable",
        "type": "function"
    },
    {
        "inputs": [
            {"internalType": "address", "name": "_oldIdentity", "type": "address"},
            {"internalType": "address", "name": "_newIdentity", "type": "address"}
        ],
        "name": "initiateCommunityRecovery",
        "outputs": [],
        "stateMutability": "nonpayable",
        "type": "function"
    }
];

const TOKEN_ABI = [
    {
        "inputs": [
            {"internalType": "address", "name": "_operator", "type": "address"},
            {"internalType": "string", "name": "_hardwareId", "type": "string"},
            {"internalType": "uint256", "name": "_gpuFlops", "type": "uint256"}
        ],
        "name": "registerComputeRig",
        "outputs": [],
        "stateMutability": "nonpayable",
        "type": "function"
    },
    {
        "inputs": [
            {"internalType": "address", "name": "_operator", "type": "address"},
            {"internalType": "uint256", "name": "_datasetTokensProcessed", "type": "uint256"}
        ],
        "name": "recordComputationWork",
        "outputs": [],
        "stateMutability": "nonpayable",
        "type": "function"
    },
    {
        "inputs": [{"internalType": "address", "name": "account", "type": "address"}],
        "name": "balanceOf",
        "outputs": [{"internalType": "uint256", "name": "", "type": "uint256"}],
        "stateMutability": "view",
        "type": "function"
    },
    {
        "inputs": [],
        "name": "totalAIVolumeProcessed",
        "outputs": [{"internalType": "uint256", "name": "", "type": "uint256"}],
        "stateMutability": "view",
        "type": "function"
    }
];

const ORACLE_ABI = [
    {
        "inputs": [
            {"internalType": "address", "name": "_operator", "type": "address"},
            {"internalType": "uint256", "name": "_tokensProcessed", "type": "uint256"},
            {"internalType": "uint256", "name": "_nonce", "type": "uint256"}
        ],
        "name": "submitAIPerformanceReport",
        "outputs": [],
        "stateMutability": "nonpayable",
        "type": "function"
    },
    {
        "inputs": [
            {"internalType": "address", "name": "_operator", "type": "address"},
            {"internalType": "uint256", "name": "_tokensProcessed", "type": "uint256"},
            {"internalType": "uint256", "name": "_nonce", "type": "uint256"}
        ],
        "name": "isReportReady",
        "outputs": [{"internalType": "bool", "name": "", "type": "bool"}],
        "stateMutability": "view",
        "type": "function"
    }
];

// Asynchronous execution context and contract cache layers
let provider = null;
let signer = null;
let hubContract = null;
let registryContract = null;
let vaultContract = null;
let tokenContract = null;
let oracleContract = null;

/**
 * Initializes the application lifecycle, handling browser environment configurations.
 */
async function initDapp() {
    if (typeof window.ethereum !== 'undefined') {
        try {
            provider = new ethers.BrowserProvider(window.ethereum);
            const accounts = await provider.listAccounts();
            
            if (accounts.length > 0) {
                signer = await provider.getSigner();
                const userAddress = accounts[0].address;
                
                await initializeContracts(signer);
                updateUIConnectedState(userAddress);
                await updateSoulStatus(userAddress);
                await updatePensionDashboard(userAddress);
            } else {
                document.getElementById('soulStatus').innerText = "Connect Wallet via MetaMask";
                await updatePensionDashboard(null);
            }
            setupEventListeners();
        } catch (error) {
            console.error("Ecosystem client failed initialization sequence:", error);
        }
    } else {
        document.getElementById('soulStatus').innerText = "MetaMask Missing";
    }
}

/**
 * Interrogates the Central Hub Factory to map addresses and initialize system bindings.
 */
async function initializeContracts(targetSignerOrProvider) {
    console.log("Interrogating Central Hub Registry at:", HUB_ADDRESS);
    hubContract = new ethers.Contract(HUB_ADDRESS, HUB_ABI, targetSignerOrProvider);
    
    // Dynamic coordinate discovery route
    REGISTRY_ADDRESS = await hubContract.getSoulRegistry();
    VAULT_ADDRESS = await hubContract.getVestingVault();
    TOKEN_ADDRESS = await hubContract.tokenCore();
    ORACLE_ADDRESS = await hubContract.networkOracle();
    
    console.log("Resolved System Mappings:\n", {
        Registry: REGISTRY_ADDRESS,
        Vault: VAULT_ADDRESS,
        Token: TOKEN_ADDRESS,
        Oracle: ORACLE_ADDRESS
    });

    // Contract entity compilation instances
    registryContract = new ethers.Contract(REGISTRY_ADDRESS, REGISTRY_ABI, targetSignerOrProvider);
    vaultContract = new ethers.Contract(VAULT_ADDRESS, VAULT_ABI, targetSignerOrProvider);
    tokenContract = new ethers.Contract(TOKEN_ADDRESS, TOKEN_ABI, targetSignerOrProvider);
    oracleContract = new ethers.Contract(ORACLE_ADDRESS, ORACLE_ABI, targetSignerOrProvider);
}

function updateUIConnectedState(address) {
    const connectBtn = document.getElementById('connectBtn');
    const accountArea = document.getElementById('accountArea');
    if (connectBtn) connectBtn.innerText = "Connection Secure";
    if (accountArea) {
        accountArea.innerText = `Identity Node Address: ${address.substring(0, 6)}...${address.substring(38)}`;
    }
}

/**
 * Requests client wallet integration credentials via window-injected standard providers.
 */
async function connectWallet() {
    if (typeof window.ethereum !== 'undefined') {
        try {
            const accounts = await window.ethereum.request({ method: 'eth_requestAccounts' });
            provider = new ethers.BrowserProvider(window.ethereum);
            signer = await provider.getSigner();
            
            await initializeContracts(signer);
            updateUIConnectedState(accounts[0]);
            await updateSoulStatus(accounts[0]);
            await updatePensionDashboard(accounts[0]);
        } catch (error) {
            console.error("User execution signature request rejected:", error);
        }
    } else {
        alert("Please install MetaMask to interface with the platform.");
    }
}

/**
 * [GRADUATED PARTICIPATION & IDENTITY TIERS]
 * Interrogates SoulRegistry profile tracking structures to render social standings.
 */
async function updateSoulStatus(userAddress) {
    const statusElement = document.getElementById('soulStatus');
    if (!statusElement || !registryContract) return;
    
    statusElement.classList.add('loading');
    
    try {
        const tierResult = await registryContract.getSoulTier(userAddress);
        const tier = Number(tierResult);
        
        const soulMap = {
            0: { label: "Unverified Soul (Tier 0)", color: "#d9534f" },
            1: { label: "Newcomer Status (Tier 1)", color: "#007bff" },
            2: { label: "Community Member (Tier 2)", color: "#28a745" },
            3: { label: "Grid Maintainer (Tier 3)", color: "#17a2b8" },
            4: { label: "Community Elder (Tier 4)", color: "#6f42c1" }
        };

        statusElement.classList.remove('loading');
        const currentSoul = soulMap[tier] || soulMap[0];
        statusElement.innerText = currentSoul.label;
        statusElement.style.color = currentSoul.color;
        statusElement.style.fontWeight = "bold";
    } catch (error) {
        console.error("Identity registry query failed:", error);
        statusElement.classList.remove('loading');
        statusElement.innerText = "Error Querying Registry";
    }
}

/**
 * [SHARES IN MUTUAL AID RESERVES]
 * Queries live data states from the token layer and vesting contract.
 */
async function updatePensionDashboard(userAddress) {
    const reserveElement = document.getElementById('reserveAmount');
    const userShareElement = document.getElementById('userShare');
    if (!reserveElement) return;

    reserveElement.classList.add('loading');
    if (userShareElement) userShareElement.classList.add('loading');

    try {
        if (!vaultContract || !userAddress) {
            reserveElement.classList.remove('loading');
            if (userShareElement) userShareElement.classList.remove('loading');
            reserveElement.innerText = "0.0000 APT";
            if (userShareElement) userShareElement.innerText = "0.0000 APT";
            return;
        }

        const rawReserves = await vaultContract.getTotalReserves();
        const rawEntitlement = await vaultContract.calculateEntitlement(userAddress);
        
        reserveElement.classList.remove('loading');
        if (userShareElement) userShareElement.classList.remove('loading');
        
        reserveElement.innerText = `${parseFloat(ethers.formatEther(rawReserves)).toFixed(4)} APT`;
        userShareElement.innerText = `${parseFloat(ethers.formatEther(rawEntitlement)).toFixed(4)} APT`;
    } catch (error) {
        console.error("Dashboard metric rendering crashed:", error);
        reserveElement.classList.remove('loading');
        if (userShareElement) userShareElement.classList.remove('loading');
        reserveElement.innerText = "Connection Error";
    }
}

/**
 * Executes token distribution allocations gated by active social standings.
 */
async function claimPension() {
    if (!signer || !vaultContract) return alert("Connection Error: Access wallet connection profile first.");

    try {
        const userAddress = await signer.getAddress();
        const tier = Number(await registryContract.getSoulTier(userAddress));

        if (tier < 2) {
            alert("Identity Validation Rejected: Only verified Community Members (Tier 2) or higher can access allocations.");
            return;
        }

        const tx = await vaultContract.release();
        console.log("Distribution transaction processing:", tx.hash);
        await tx.wait();
        
        alert("Mutual Aid allocation successfully distributed to your wallet address!");
        await updatePensionDashboard(userAddress);
    } catch (error) {
        console.error("Transaction processing encountered error:", error);
        alert("Transaction aborted: Verify allocation window conditions are met.");
    }
}

/**
 * =====================================================================================
 * ADVANCED PLURALITY ASPECT EXPERIMENTAL TESTING SUITE
 * =====================================================================================
 */

/**
 * [TESTING FUNCTION: CONVERT AI METRICS INTO MUTUAL AID RESERVES via DECOUPLED SETTIEMENT]
 * Orchestrates validator signature verification before executing token distributions.
 */
async function simulateAIPerformancePipeline(operatorAddress, tokensProcessed, nonce) {
    if (!oracleContract || !tokenContract) return alert("System Core uninitialized.");
    console.log(`Starting experimental testing framework sequence for operator: ${operatorAddress}`);

    try {
        // Phase 1: Interrogate Oracle data validation consensus map
        console.log("Step 1: Interrogating Oracle consensus validation threshold...");
        const isReady = await oracleContract.isReportReady(operatorAddress, tokensProcessed, nonce);
        
        if (!isReady) {
            console.log("Quorum unsatisfied. Injecting cryptographic validator node verification signature...");
            const tx1 = await oracleContract.submitAIPerformanceReport(operatorAddress, tokensProcessed, nonce);
            console.log("Mining validator consensus transaction:", tx1.hash);
            await tx1.wait();
            console.log("✔ Threshold Quorum requirement satisfied by signature authorization.");
        } else {
            console.log("✔ Oracle Consensus confirmation history verified for target data payload.");
        }

        // Phase 2: Decoupled Token Settlement Action Execution
        console.log("Step 2: Dispatching decoupled settlement execution message to Core Token Engine...");
        const tx2 = await tokenContract.recordComputationWork(operatorAddress, tokensProcessed);
        console.log("Settlement mining active:", tx2.hash);
        await tx2.wait();
        
        console.log("🎉 Success: 80% rewards minted to Operator, 20% routed to Mutual Aid Vault.");
        alert("Decoupled metric processing complete. Hardware telemetry converted to reserves!");
        
        // Refresh values across the active UI context
        const activeUser = await signer.getAddress();
        await updatePensionDashboard(activeUser);
    } catch (error) {
        console.error("Decoupled pipeline processing error:", error);
        alert(`Pipeline execution error: ${error.reason || error.message}`);
    }
}

/**
 * [TESTING FUNCTION: ALLOCATIONS OF SOULBOUND TOKENS & IDENTITY TIERS]
 * Mints an identity profile layer directly into the immutable registry mapping database.
 */
async function executeSoulboundMint(targetAddress, targetTier) {
    if (!registryContract) return alert("Soul Registry interface disconnected.");
    console.log(`Executing non-transferable SBT profiling sequence for destination: ${targetAddress}`);

    try {
        const tx = await registryContract.mintSoulProfile(targetAddress, targetTier);
        console.log("Processing immutable identity certification:", tx.hash);
        await tx.wait();
        
        alert(`🎉 Soulbound Profile initialized. Identity set to Tier ${targetTier}!`);
        await updateSoulStatus(targetAddress);
    } catch (error) {
        console.error("SBT minting validation crashed:", error);
        alert(`SBT Generation Failed: Admin permissions required.`);
    }
}

/**
 * [TESTING FUNCTION: COMMUNITY RECOVERY - GUARDIAN DESIGNATION]
 * Assigns an array of trusted peer wallet addresses to protect your digital identity structure.
 */

/**
 * [TESTING FUNCTION: COMMUNITY RECOVERY - GUARDIAN DESIGNATION]
 * Assigns an array of trusted peer wallet addresses to protect your digital identity structure.
 */
async function registerRecoveryCircle(guardianAddressesArray) {
    if (!registryContract) return alert("Soul Registry interface disconnected.");
    console.log("Binding alternative recovery circle mapping structures:", guardianAddressesArray);

    try {
        // Change '.setTrustedGuardians' to '.setGuardians' to match your smart contract source code!
        const tx = await registryContract.setGuardians(guardianAddressesArray);
        console.log("Writing social guardian coordination profiles to state registry:", tx.hash);
        await tx.wait();
        
        alert("✔ Trusted peer circle successfully registered as cryptographic identity guardians.");
    } catch (error) {
        console.error("Guardian allocation routine rejected:", error);
        alert("Guardian Allocation Error: Check registration state requirements.");
    }
}

/**
 * [TESTING FUNCTION: COMMUNITY RECOVERY - RECOVERY EXECUTION]
 * Simulates executing social recovery when a user's master private key is compromised.
 */
async function executeSocialIdentityRecovery(oldIdentityAddress, newSecureAddress) {
    if (!registryContract) return alert("Soul Registry interface disconnected.");
    console.log(`Triggering social consensus rescue routine to point reputation layer to new identity account...`);

    try {
        const tx = await registryContract.initiateCommunityRecovery(oldIdentityAddress, newSecureAddress);
        console.log("Processing cryptographic rescue sequence across registry state storage:", tx.hash);
        await tx.wait();
        
        alert("🎉 Identity structure rescued! Soul parameters safely redirected.");
        await updateSoulStatus(newSecureAddress);
    } catch (error) {
        console.error("Social consensus rescue execution failure:", error);
        alert("Recovery Action Aborted: Active validator signer lacks peer authentication authority.");
    }
}

/**
 * Configures event notification state hooks across the local window client ecosystem.
 */
function setupEventListeners() {
    window.ethereum.on('accountsChanged', (accounts) => {
        if (accounts.length === 0) {
            location.reload();
        } else {
            initDapp();
        }
    });

    window.ethereum.on('chainChanged', () => {
        location.reload();
    });
}

// Bind main entry block listener hook
window.addEventListener('DOMContentLoaded', initDapp);