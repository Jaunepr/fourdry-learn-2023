// SPDX-License-Identifier:MIT
pragma solidity ^0.8.23;

import {Script} from "forge-std/Script.sol";
import {FundMe} from "../src/FundMe.sol";
import {HelperConfig} from "./HelperConfig.s.sol";

contract DeployFundMe is Script {
    function run() external returns (FundMe) {
        // 本地模拟合约,before startBroadcast -> Not a "real" tx
        HelperConfig helperConfig = new HelperConfig();
        address ethUsdPriceFeed = helperConfig.activeNetworkConfig();
        vm.startBroadcast();
        FundMe fundMe = new FundMe(ethUsdPriceFeed); //有sepolia地址，不加url测试会失败；
        vm.stopBroadcast();
        return fundMe;
    }
}
