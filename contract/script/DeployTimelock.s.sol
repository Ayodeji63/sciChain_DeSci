// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

import {Script} from "forge-std/Script.sol";
import {SciChain} from "../src/SciChain.sol";
import {GovToken} from "../src/GovToken.sol";
import {TimeLock} from "../src/TimeLock.sol";
import {MyGovernor} from "../src/MyGovernor.sol";
import {DevOpsTools} from "foundry-devops/src/DevOpsTools.sol";

contract DeployTimeLock is Script {
    TimeLock timelock;
    uint256 public constant MIN_DELAY = 3600;
    address[] proposers;
    address[] executors;
    function run() public {
    vm.startBroadcast();
    timelock = new TimeLock(MIN_DELAY, proposers, executors);
    vm.stopBroadcast();
    }
}