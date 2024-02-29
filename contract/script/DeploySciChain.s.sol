// SPDX-License-Identifier: MIT

pragma solidity ^0.8.18;

import {Script} from "forge-std/Script.sol";
import {SciChain} from "../src/SciChain.sol";

contract DeploySciChain is Script {
    uint256 privateKey = uint256(vm.envBytes32("OP_PRIVATE_KEY"));
    address public  _initAdmin = vm.addr(privateKey);
    address public  _fundWallet = _initAdmin;
    uint256 public constant _feeRate = 100;
    uint256 public constant _callbackGasLimit = 1_000_000;
    uint8 public constant _failureHandleStrategy = 0;

    SciChain sciChain;

    function run() public {
    vm.startBroadcast();
    sciChain = new SciChain();  
    sciChain.initialize(_initAdmin, _fundWallet, _feeRate, _callbackGasLimit, _failureHandleStrategy);
    vm.stopBroadcast();
    }
}

