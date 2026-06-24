// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import { Script, console } from "lib/forge-std/src/Script.sol";
import { MinimalAccount } from "src/ethereum/MinimalAccount.sol";
import { EntryPoint } from "lib/account-abstraction/contracts/core/EntryPoint.sol";

contract HelperConfig is Script {
    error HelperConfig__InvalidChainId();

    struct NetworkConfig {
        address entryPoint;
        address account;
    }

    uint256 constant ETH_SEPOLIA_CHIAN_ID = 11155111;
    uint256 constant ZKSYNC_CHIAN_ID = 300;
    uint256 constant LOCAL_CHIAN_ID = 31337;
    address constant BURNER_WALLET = 0xd4bD9a13058A2Ff4Da5Cf699e51432aDA67aA84B;
    address constant FOUNDRY_DEFAULT_WALLET = 0x1804c8AB1F12E6bbf3894d4083f33e07309d1f38;
    address constant ANVIL_DEFAULT_ACCOUNT = 0xf39Fd6e51aad88F6F4ce6aB8827279cffFb92266;

    NetworkConfig public localNetworkConfig;
    mapping(uint256 chainid => NetworkConfig) public networkConfigs;

    constructor() {
        networkConfigs[ETH_SEPOLIA_CHIAN_ID] = getEthSepoliaConfig();
    }

    function getConfig() public returns(NetworkConfig memory) {
        return getConfigByChainId(block.chainid);
    }

    function getConfigByChainId(uint256 chainId) public returns(NetworkConfig memory) {
        if (chainId == LOCAL_CHIAN_ID) {
            return getOrCreateAnvilEthConfig();
        } else if(networkConfigs[chainId].entryPoint != address(0)) {
            return networkConfigs[chainId];
        } else {
            revert HelperConfig__InvalidChainId();
        }
    }

    function getEthSepoliaConfig() public pure returns (NetworkConfig memory) {
        return NetworkConfig({ entryPoint: 0x5FF137D4b0FDCD49DcA30c7CF57E578a026d2789, account: BURNER_WALLET });
    }

    function getZkSyncSepoliaConfig() public pure returns (NetworkConfig memory) {
        return NetworkConfig({entryPoint: address(0), account: BURNER_WALLET});
    }

    function getOrCreateAnvilEthConfig() public returns (NetworkConfig memory) {
        if (localNetworkConfig.account != address(0)) {
            return localNetworkConfig;
        }

        // deploy a mock entry point contract
        console.log("Deploying mocks...");
        vm.startBroadcast(ANVIL_DEFAULT_ACCOUNT);
        EntryPoint entryPoint = new EntryPoint();
        vm.stopBroadcast();

        localNetworkConfig =  NetworkConfig({ entryPoint: address(entryPoint), account: ANVIL_DEFAULT_ACCOUNT });

        return localNetworkConfig;
    }
}
