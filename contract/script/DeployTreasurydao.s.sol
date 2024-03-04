
// SPDX-License-Identifier: MIT

pragma solidity ^0.8.18;

import {Script} from "forge-std/Script.sol";
import {SciChain} from "../src/SciChain.sol";
import {GovToken} from "../src/GovToken.sol";
import {TimeLock} from "../src/TimeLock.sol";
import {MyGovernor} from "../src/MyGovernor.sol";
import {DevOpsTools} from "foundry-devops/src/DevOpsTools.sol";
import {TreasuryDAO} from "../src/TreasuryDAO.sol";

contract DeployTreasurydao is Script {
    TreasuryDAO dao;

    function run() public {
        address sciChain = DevOpsTools.get_most_recent_deployment(
            "SciChain",
            block.chainid
        );

        vm.startBroadcast();
        deployTreasuryDao(sciChain);
        vm.stopBroadcast();
    }

    function deployTreasuryDao (address _sciChain) public {
        SciChain sciChain = SciChain(_sciChain);
        dao = new TreasuryDAO(address(sciChain));
    }
}