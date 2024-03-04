
// SPDX-License-Identifier: MIT

pragma solidity ^0.8.18;

import {Script} from "forge-std/Script.sol";
import {SciChain} from "../src/SciChain.sol";
import {GovToken} from "../src/GovToken.sol";
import {TimeLock} from "../src/TimeLock.sol";
import {MyGovernor} from "../src/MyGovernor.sol";
import {DevOpsTools} from "foundry-devops/src/DevOpsTools.sol";

contract DeployGovernor is Script {
    MyGovernor governor;

    function run() public {
        address token = DevOpsTools.get_most_recent_deployment(
            "GovToken",
            block.chainid
        );
        address timelock = DevOpsTools.get_most_recent_deployment(
            "TimeLock",
            block.chainid
        );

        vm.startBroadcast();
        deployGovernor(token, timelock);
        vm.stopBroadcast();
    }

    function deployGovernor (address _token, address _timelock) public {
        GovToken token = GovToken(_token);
        TimeLock timelock = TimeLock(payable(_timelock));
        governor = new MyGovernor(token, timelock);
        
    }
}