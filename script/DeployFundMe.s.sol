//SPDX-License-Identifier: GPL-3.0

pragma solidity ^0.8.24;

import {Script} from "forge-std/Script.sol";
import {fundMe} from "../src/fundMe.sol";
import {HelperConfig} from "../script/HelperConfig.s.sol";

contract DeployFundMe is Script {
    fundMe fundme;
    address priceFeed;
    HelperConfig config;

    function run() external returns (fundMe, HelperConfig) {
        config = new HelperConfig();
        priceFeed = config.activeNetworkConfig();
        vm.startBroadcast();
        fundme = new fundMe(priceFeed);
        vm.stopBroadcast();
        return (fundme, config);
    }
}
