// SPDX-License-Identifier: MIT

pragma solidity ^0.8.23;

import {Script} from "forge-std/Script.sol";
import {MockV3Aggregator} from "../test/mocks/MockV3Aggregator.sol";

contract HelperConfig is Script {
    // If we are on a local anvil, we deploy mocks contract
    // Otherwise, grab the existing address from the live network

    // make configs transfer to our type! it's good idea
    NetworkConfig public activeNetworkConfig;
    uint8 public constant DECIMAL = 8;
    int256 public constant INITIAL_PRICE = 2000e8;

    struct NetworkConfig {
        address priceFeed_address; // ETH/USD price
    }

    constructor() {
        if (block.chainid == 11155111) {
            activeNetworkConfig = getSepoliaEthConfig();
        } else {
            activeNetworkConfig = getOrCreateAnvilethConfig();
        }
    }

    function getSepoliaEthConfig() public pure returns (NetworkConfig memory) {
        // price feed address
        NetworkConfig memory sepoliaConfig = NetworkConfig({
            priceFeed_address: 0x694AA1769357215DE4FAC081bf1f309aDC325306
        });
        return sepoliaConfig;
    }

    function getOrCreateAnvilethConfig() public returns (NetworkConfig memory) {
        if (activeNetworkConfig.priceFeed_address != address(0)) {
            return activeNetworkConfig;
        }
        // price feed address

        // 1.Deploy the mocks
        // 2.Return the mock address

        vm.startBroadcast();
        MockV3Aggregator mockPriceFeed = new MockV3Aggregator(
            DECIMAL,
            INITIAL_PRICE
        );
        vm.stopBroadcast();

        NetworkConfig memory anvilConfig = NetworkConfig({
            priceFeed_address: address(mockPriceFeed)
        });
        return anvilConfig;
    }
}
// 1. 部署模拟合约用来交互 when we are on a local anvil chain
// 2. Keep track of contract address from different chains
// Sepolia ETH/USD has different address
// mainnet ETH/USD
