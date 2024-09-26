//SPDX-License-Identifier: GPL-3.0

pragma solidity ^0.8.24;

import {Script} from "forge-std/Script.sol";
import {fundMe} from "../src/fundMe.sol";
import {MockV3Aggregator} from "../test/Mocks/MockAggregatorV3Interface.sol";

contract HelperConfig is Script {
    struct NetworkConfig {
        address priceFeed;
    }

    NetworkConfig public activeNetworkConfig;

    constructor() {
        if (block.chainid == 11155111) activeNetworkConfig = getSepoliaNetworkConfig();
        else activeNetworkConfig = getAnvilNetworkConfig();
    }

    function getSepoliaNetworkConfig() public pure returns (NetworkConfig memory) {
        return NetworkConfig(0x694AA1769357215DE4FAC081bf1f309aDC325306);
    }

    function getAnvilNetworkConfig() public returns (NetworkConfig memory anvilConfig) {
        if (activeNetworkConfig.priceFeed != address(0)) {
            return anvilConfig;
        }

        vm.startBroadcast();
        MockV3Aggregator mockFeed = new MockV3Aggregator(8, 2000e8);
        vm.stopBroadcast();
        anvilConfig = NetworkConfig({priceFeed: address(mockFeed)});
        return anvilConfig;
    }
}
