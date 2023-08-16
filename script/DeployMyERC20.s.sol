// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

import {Script} from "forge-std/Script.sol";
import {MyERC20} from "../src/MyERC20.sol";

contract DeployMyERC20 is Script {
    uint256 constant INITIAL_SUPPLY = 1000 ether;

    function run() external returns (MyERC20 myERC20) {
        vm.startBroadcast();
        myERC20 = new MyERC20(INITIAL_SUPPLY);
        vm.stopBroadcast();
    }
}
