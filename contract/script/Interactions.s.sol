// SPDX-License-Identifier: MIT

pragma solidity ^0.8.18;
import {DevOpsTools} from "foundry-devops/src/DevOpsTools.sol";
import {SciChain} from "../src/SciChain.sol";
import {TimeLock} from "../src/TimeLock.sol";
import {Script} from "forge-std/Script.sol";
import {TreasuryDAO} from "../src/TreasuryDAO.sol";
import {MyGovernor} from "../src/MyGovernor.sol";
import {console} from "forge-std/console.sol";


contract listProposal is Script {

    SciChain sciChain;
    uint256 privateKey = uint256(vm.envBytes32("OP_PRIVATE_KEY"));
    address public  SCIENTIST = vm.addr(privateKey);
    uint256 GROUP_ID = 1916;
    string public constant title = "Biomedical Research";
    string public constant description = "Biomedical Research description";
    function setUp() public {
        address _sciChain =DevOpsTools.get_most_recent_deployment("SciChain", block.chainid);
        sciChain = SciChain(_sciChain);
    }

    function run() public {
        vm.startBroadcast(SCIENTIST);
        sciChain.listProposal(title, description, GROUP_ID);
        vm.stopBroadcast();
    }
}

contract reviewProposal is Script {
    SciChain sciChain;
    uint256 privateKey = uint256(vm.envBytes32("OP_PRIVATE_KEY"));
    address public  REVIEWER = vm.addr(privateKey);
    uint256 REVIEW_SCORE = 3; 
    // low 1, high 5

    function setUp() public {
        address _sciChain =DevOpsTools.get_most_recent_deployment("SciChain", block.chainid);
        sciChain = SciChain(_sciChain);
    }

    function run() public {
        vm.startBroadcast(REVIEWER);
        uint256 proposalId = sciChain.proposalCounter();
        sciChain.reviewProposal(proposalId, REVIEW_SCORE);
        vm.stopBroadcast();
    }

}

contract publishProposal is Script {
    SciChain sciChain;
    uint256 privateKey = uint256(vm.envBytes32("OP_PRIVATE_KEY"));
    address public PUBLISHER = vm.addr(privateKey);
    uint256 REVIEW_SCORE = 3;

    function setUp() public {
        address _sciChain =DevOpsTools.get_most_recent_deployment("SciChain", block.chainid);
        sciChain = SciChain(_sciChain);
    }

    function run() public {
        vm.startBroadcast(PUBLISHER);
        uint256 proposalId = sciChain.proposalCounter();
        sciChain.publishProposal(proposalId);
        vm.stopBroadcast();
    }

}

contract proposeFunding is Script {
    address[] proposers;
    address[] executors;
    bytes[] functionCalls;
    address[] addressesToCall;
    uint256[] values;

    TimeLock timelock;
    TreasuryDAO treasury;
    MyGovernor governor;
    SciChain sciChain;
    uint256 privateKey = uint256(vm.envBytes32("OP_PRIVATE_KEY"));
    address public OWNER = vm.addr(privateKey);
    uint256 REVIEW_SCORE = 3;
    uint256 public constant PROJECT_FUND = 0.001 ether;
    address public constant RECIPIENT = 0x180E165916D6B4604b63012fa86A28956eB0c639;

    function setUp() public {
        address _sciChain =DevOpsTools.get_most_recent_deployment("SciChain", block.chainid);
        sciChain = SciChain(_sciChain);
        address _govenor = DevOpsTools.get_most_recent_deployment("MyGovernor", block.chainid);
        address _treasury = DevOpsTools.get_most_recent_deployment("TreasuryDAO", block.chainid);
        treasury = TreasuryDAO(payable(_treasury));
        governor = MyGovernor(payable(_govenor));
        
        uint256 proposalId = sciChain.proposalCounter();
        bytes memory encodedFunctionCall = abi.encodeWithSignature("fundProject(address,uint256,uint256)", RECIPIENT, proposalId, PROJECT_FUND); 
        addressesToCall.push(address(treasury));
        values.push(0);
        functionCalls.push(encodedFunctionCall);

    }

    function run() public {
        vm.startBroadcast(OWNER);
        string memory _description = "Fund published proposal by SciChain contract";
        uint256 _proposalId = governor.propose(addressesToCall, values, functionCalls, _description);
        console.log("Proposal Status: ", uint256(governor.state(_proposalId)));
        vm.stopBroadcast();
    }
}

contract Vote is Script {
    MyGovernor governor;
    SciChain sciChain;
    uint256 privateKey = uint256(vm.envBytes32("OP_PRIVATE_KEY"));
    address public VOTER = vm.addr(privateKey);
    string public constant _description = "Biomedical Research description";
    address[] proposers;
    address[] executors;
    bytes[] functionCalls;
    address[] addressesToCall;
    uint256[] values;

    function setUp() public {
        address _govenor = DevOpsTools.get_most_recent_deployment("MyGovernor", block.chainid);
        governor = MyGovernor(payable(_govenor));
        address _sciChain =DevOpsTools.get_most_recent_deployment("SciChain", block.chainid);
        sciChain = SciChain(_sciChain);

    }

    function run() public {
        vm.startBroadcast(VOTER);
        uint256 _proposalId = governor.propose(addressesToCall, values, functionCalls, _description);

        string memory reason = "I'm curious about what unfolds for humanity";
        uint8 voteWay = 1;
        governor.castVoteWithReason(_proposalId, voteWay, reason);
        vm.stopBroadcast();
    }
}

contract transferOwnership is Script {
    TimeLock timelock;
    TreasuryDAO treasury;
    MyGovernor governor;
    uint256 privateKey = uint256(vm.envBytes32("OP_PRIVATE_KEY"));
    address public PUBLISHER = vm.addr(privateKey);
    uint256 REVIEW_SCORE = 3;

    function setUp() public {
        address _timelock =DevOpsTools.get_most_recent_deployment("TimeLock", block.chainid);
        timelock = TimeLock(payable(_timelock));
        address _treasurydao = DevOpsTools.get_most_recent_deployment("TreasuryDAO", block.chainid);
        treasury = TreasuryDAO(payable(_treasurydao));
        address _govenor = DevOpsTools.get_most_recent_deployment("MyGovernor", block.chainid);
        governor = MyGovernor(payable(_govenor));

    }

    function run() public {
        vm.startBroadcast(PUBLISHER);
        // treasury.transferOwnership(address(timelock)); 
        bytes32 proposerRole = timelock.PROPOSER_ROLE();
        bytes32 executorRole = timelock.EXECUTOR_ROLE();
        bytes32 adminRole = timelock.TIMELOCK_ADMIN_ROLE();

        timelock.grantRole(proposerRole, address(governor));
        timelock.grantRole(executorRole, address(0));
        timelock.revokeRole(adminRole, msg.sender);
        vm.stopBroadcast();
    }
}
































