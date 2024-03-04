// SPDX-License-Identifier: MIT

pragma solidity ^0.8.18;

import {Script} from "forge-std/Script.sol";
import {SciChain} from "../src/SciChain.sol";
import {GovToken} from "../src/GovToken.sol";
import {TimeLock} from "../src/TimeLock.sol";
import {MyGovernor} from "../src/MyGovernor.sol";
import {DevOpsTools} from "foundry-devops/src/DevOpsTools.sol";

contract DeployGovToken is Script {

    GovToken govToken;

    function run() public {
    vm.startBroadcast();
    govToken = new GovToken();
    vm.stopBroadcast();
    }
}



