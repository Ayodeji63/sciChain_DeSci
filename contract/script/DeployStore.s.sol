// SPDX-License-Identifier: MIT

pragma solidity ^0.8.18;

import {Script} from "forge-std/Script.sol";
import {Store} from "../src/Test.sol";

contract DeployStore is Script {

    Store store;

    function run() public {
    vm.startBroadcast();
    store = new Store();
    vm.stopBroadcast();
    }
}



