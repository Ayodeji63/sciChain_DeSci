// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

import {Test, console} from "forge-std/Test.sol";
import {MyGovernor} from "../src/MyGovernor.sol";
import {GovToken} from "../src/GovToken.sol";
import {TimeLock} from "../src/TimeLock.sol";
import {TreasuryDAO} from "../src/TreasuryDAO.sol";
import {SciChain} from "../src/SciChain.sol";
import {SciChainTest} from "./SciChainTest.t.sol";

contract MyGovernorTest is Test {
    GovToken token;
    TimeLock timelock;
    MyGovernor governor;
    TreasuryDAO treasury;
    SciChain sciChain;
    SciChainTest sciChainTest;

    uint256 public constant MIN_DELAY = 3600;
    uint256 public constant QUOROM_PERCENTAGE = 4;
    uint256 public constant VOTING_PERIOD = 50400;
    uint256 public constant VOTING_DELAY = 1;
    address public RECIPIENT = makeAddr("recipeint");
    uint256 public AMOUNT = 100 ether;

    address[] proposers;
    address[] executors;
    bytes[] functionCaslls;
    address[] addressesToCall;
    uint256[] values;

    address public constant VOTER = address(1);

    function setUp() public {
        token = new GovToken();
        token.mint(VOTER, 100e18);
        sciChain = new SciChain();

        vm.prank(VOTER);
        token.delegate(VOTER);
        timelock = new TimeLock(MIN_DELAY, proposers, executors);
        governor = new MyGovernor(token, timelock);
        bytes32 proposerRole = timelock.PROPOSER_ROLE();
        bytes32 executorRole = timelock.EXECUTOR_ROLE();
        bytes32 adminRole = timelock.TIMELOCK_ADMIN_ROLE();

        timelock.grantRole(proposerRole, address(governor));
        timelock.grantRole(executorRole, address(0));
        timelock.revokeRole(adminRole, msg.sender);

        treasury = new TreasuryDAO(address(sciChain));
        treasury.transferOwnership(address(timelock)); 
    }

    function testCantFundProjectWithoutGovernance() public {
        vm.expectRevert();
        treasury.fundProject(RECIPIENT, 1, AMOUNT);
    }
}
