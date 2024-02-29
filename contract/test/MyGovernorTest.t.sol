// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

import {Test, console} from "forge-std/Test.sol";
import {MyGovernor} from "../src/MyGovernor.sol";
import {GovToken} from "../src/GovToken.sol";
import {TimeLock} from "../src/TimeLock.sol";
import {TreasuryDAO} from "../src/TreasuryDAO.sol";
import {SciChain} from "../src/SciChain.sol";
import {SciChainTest} from "./SciChainTest.t.sol";
import {console} from "forge-std/console.sol";
import "@bnb-chain/greenfield-contracts/contracts/interface/IGroupHub.sol";
import "../src/SciChain.sol";
import {ISciChain} from "../src/Interfaces/ISciChain.sol";

interface IERC721GROUP {
    function mint(address to, uint256 tokenId) external;
}

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
    bytes[] functionCalls;
    address[] addressesToCall;
    uint256[] values;

    address public constant VOTER = address(1);
    uint256 public constant AVERAGE_REVIEW_SCORE = 3;
    


    uint256 privateKey = uint256(vm.envBytes32("OP_PRIVATE_KEY"));
    address public  _initAdmin = vm.addr(privateKey);
    address public  _fundWallet = _initAdmin;
    address public groupToken;
    address public groupHub;
    address public crossChain;
    uint256 public constant _feeRate = 100;
    uint256 public constant PROJECT_FUND = 10 ether;
    uint256 public constant _callbackGasLimit = 1_000_000;
    uint8 public constant _failureHandleStrategy = 0;
    address public REVIEWER = makeAddr("reviewer");
    address public REVIEWER2 = makeAddr("reviewer2");
    address public REVIEWER3 = makeAddr("reviewer3");
    address public REVIEWER4 = makeAddr("reviewer4");
    address public REVIEWER5 = makeAddr("reviewer5");

    address[] public reviewers;

    uint256 public constant REVIEW_SCORE = 2;
    

    string public constant title = "Biomedical Research";
    string public constant description = "Biomedical Research description";



    function setUp() public {
        token = new GovToken();
        token.mint(VOTER, 100e18);
        sciChain = new SciChain();
        sciChain.initialize(_initAdmin, _fundWallet, _feeRate, _callbackGasLimit, _failureHandleStrategy);
        groupHub = sciChain.GROUP_HUB_D();
        groupToken = sciChain.GROUP_TOKEN();
        crossChain = sciChain.CROSS_CHAIN();

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
        treasury.deposit{value: 2000 ether}();
    }

    modifier listAndPublishProposal() {
        uint256 tokenId = 1;
        vm.assume(!IERC721NonTransferable(groupToken).exists(tokenId));
        vm.startPrank(groupHub);
        IERC721GROUP(groupToken).mint(address(this), tokenId);
        vm.stopPrank();
        vm.prank(_initAdmin);
        sciChain.addReviewer(REVIEWER);
        sciChain.listProposal(title, description, tokenId);
        uint256 proposalId = sciChain.proposalCounter();
        vm.prank(REVIEWER);
        sciChain.reviewProposal(proposalId, REVIEW_SCORE);
        vm.prank(_initAdmin);
        sciChain.publishProposal(proposalId);
        _;
    }

    function testCantFundProjectWithoutGovernance() public {
        vm.expectRevert();
        treasury.fundProject(RECIPIENT, 1, AMOUNT);
    }

    function test_governance_can_fund_project_with_timelock() listAndPublishProposal public {
        uint256 proposalId = sciChain.proposalCounter();
        console.log("SciChain Proposal: %d", proposalId);
        string memory _description = "Fund published proposal by SciChain contract";
        bytes memory encodedFunctionCall = abi.encodeWithSignature("fundProject(address,uint256,uint256)", RECIPIENT, proposalId, PROJECT_FUND); 
        addressesToCall.push(address(treasury));
        values.push(0);
        functionCalls.push(encodedFunctionCall);
        // 1. Propose to DAO
        uint256 _proposalId = governor.propose(addressesToCall, values, functionCalls, _description);

        console.log("Proposal Status: ", uint256(governor.state(_proposalId)));

        vm.warp(block.timestamp + VOTING_DELAY + 1);
        vm.roll(block.number + VOTING_DELAY + 1);

        console.log("Proposal State:", uint256(governor.state(_proposalId)));

        // 2. Vote
        string memory reason = "I'm curious about what unfolds for humanity";
        uint8 voteWay = 1;
        vm.prank(VOTER);
        governor.castVoteWithReason(_proposalId, voteWay, reason);

        vm.warp(block.timestamp + VOTING_PERIOD + 1);
        vm.roll(block.number + VOTING_PERIOD + 1);

        console.log("Proposal State:", uint256(governor.state(_proposalId)));
        
        // 3. Queue
        bytes32 descriptionHash = keccak256(abi.encodePacked(_description));
        governor.queue(addressesToCall, values, functionCalls, descriptionHash);
        vm.roll(block.number + MIN_DELAY + 1);
        vm.warp(block.timestamp + MIN_DELAY + 1);

        // 4. Execute
        governor.execute(addressesToCall, values, functionCalls, descriptionHash);
        
        assert(address(RECIPIENT).balance == PROJECT_FUND);

    }
}
