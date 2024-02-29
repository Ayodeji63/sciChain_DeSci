// SPDX-License-Identifier: MIT

pragma solidity ^0.8.18;

import "forge-std/Test.sol";
import {console} from "forge-std/console.sol";
import "@bnb-chain/greenfield-contracts/contracts/interface/IGroupHub.sol";
import "../src/SciChain.sol";
import {ISciChain} from "../src/Interfaces/ISciChain.sol";

interface IERC721GROUP {
    function mint(address to, uint256 tokenId) external;
}

contract SciChainTest is Test {

    event ProposalListed(uint256 indexed proposalId, address indexed owner, uint256 indexed groupId, uint256 timestamp);
    event DelistProposal(uint256 indexed proposalId, uint256 indexed groupId);
    event ReviewerAdded();
    event ProposalReviewed(uint256 indexed proposalId, address indexed reviewer, uint256 reviewScore, uint256 timestamp);
    event ProposalPublished(uint256 indexed proposalId, address indexed publisher, uint256 timestamp);



    SciChain public sciChain;

    uint256 privateKey = uint256(vm.envBytes32("OP_PRIVATE_KEY"));
    address public  _initAdmin = vm.addr(privateKey);
    address public  _fundWallet = _initAdmin;
    address public groupToken;
    address public groupHub;
    address public crossChain;
    uint256 public constant _feeRate = 100;
    uint256 public constant _callbackGasLimit = 1_000_000;
    uint8 public constant _failureHandleStrategy = 0;
    address public REVIEWER = makeAddr("reviewer");
    address public REVIEWER2 = makeAddr("reviewer2");
    address public REVIEWER3 = makeAddr("reviewer3");
    address public REVIEWER4 = makeAddr("reviewer4");
    address public REVIEWER5 = makeAddr("reviewer5");

    address[] public reviewers;

    uint256 public constant REVIEW_SCORE = 2;
    uint256 public constant AVERAGE_REVIEW_SCORE = 3;
    

    string public constant title = "Biomedical Research";
    string public constant description = "Biomedical Research description";

    
    function setUp() public {
        sciChain = new SciChain();
        sciChain.initialize(_initAdmin, _fundWallet, _feeRate, _callbackGasLimit, _failureHandleStrategy);
        groupHub = sciChain.GROUP_HUB_D();
        groupToken = sciChain.GROUP_TOKEN();
        crossChain = sciChain.CROSS_CHAIN();
    }

    modifier listProposal() {
        uint256 tokenId = 1;
        vm.assume(!IERC721NonTransferable(groupToken).exists(tokenId));
        vm.startPrank(groupHub);
        IERC721GROUP(groupToken).mint(address(this), tokenId);
        vm.stopPrank();
        sciChain.listProposal(title, description, tokenId);
         _;
    }

    modifier addReviewer() {
        vm.startPrank(_initAdmin);
        sciChain.addReviewer(REVIEWER);
        reviewers.push(REVIEWER);
        sciChain.addReviewer(REVIEWER2);
        reviewers.push(REVIEWER2);
        sciChain.addReviewer(REVIEWER3);
        reviewers.push(REVIEWER3);
        sciChain.addReviewer(REVIEWER4);
        reviewers.push(REVIEWER4);
        sciChain.addReviewer(REVIEWER5);
        reviewers.push(REVIEWER5);
        vm.stopPrank();
        _;
    }

    function testList(uint256 tokenId) public {
        vm.assume(!IERC721NonTransferable(groupToken).exists(tokenId));

        // failed with unexisted group
        vm.expectRevert("ERC721: invalid token ID");
        sciChain.listProposal(title, description, tokenId);

        vm.startPrank(groupHub);
        IERC721GROUP(groupToken).mint(address(this), tokenId);
        vm.stopPrank();

        // failed with not group owner
        vm.startPrank(address(0x1234));
        vm.expectRevert("SciChain: only group owner");
        sciChain.listProposal(title, description, tokenId);
        vm.stopPrank();

        // success case
        // IGroupHub(groupHub).grant(address(sciChain), 4, 0);
        vm.expectEmit(true, true, true, false, address(sciChain));
        emit ProposalListed(1, address(this), tokenId, block.timestamp);
        sciChain.listProposal(title, description, tokenId);
    }

    function testDelist() public {
        uint256 tokenId = 1;
        uint256 proposalId = 1;
        vm.assume(!IERC721NonTransferable(groupToken).exists(tokenId));

        vm.prank(groupHub);
        IERC721GROUP(groupToken).mint(address(this), tokenId);

        vm.expectRevert("SciChain: not listed");
        sciChain.delistProposal(tokenId, proposalId);

        sciChain.listProposal(title, description, tokenId);

        vm.startPrank(address(0x1234));
        vm.expectRevert("SciChain: only group owner");
        sciChain.delistProposal(tokenId, proposalId);
        vm.stopPrank();

        // success case
        sciChain.listProposal(title, description, tokenId);
        vm.expectEmit(true, true, false, false, address(sciChain));
        emit DelistProposal(proposalId, tokenId);
        sciChain.delistProposal(tokenId, 1);

    }

    function testAddReviewer () public {
        // expected revert
        vm.expectRevert("SciChain: only owner");
        sciChain.addReviewer(REVIEWER);

        // success case
        vm.startPrank(_initAdmin);
        sciChain.addReviewer(REVIEWER);
        bool hasRole = sciChain.hasRole(sciChain.REVIEWER_ROLE(), REVIEWER);
        assert(hasRole == true);
        assertTrue(hasRole);
        vm.stopPrank();
    }

    function test_add_reviewer_can_add_already_existed_account() public listProposal addReviewer {
        vm.expectRevert("SciChain: account already added");
        vm.prank(_initAdmin);
        sciChain.addReviewer(REVIEWER);
    }

    function testReviewProposal() public listProposal addReviewer {
        // expect revert
        vm.expectRevert("SciChain: caller is not a reviewer");
        sciChain.reviewProposal(1, REVIEW_SCORE);

        // expect revert if proposal is not listed
        uint256 proposalCounter = sciChain.proposalCounter();

        vm.startPrank(REVIEWER);
        vm.expectRevert("SciChain: proposal not listed");
        sciChain.reviewProposal(2, REVIEW_SCORE);
        vm.expectRevert("SciChain: review score too low");
        sciChain.reviewProposal(1, 0);

        vm.expectEmit(true, true, false, false, address(sciChain));
        emit ProposalReviewed(proposalCounter, REVIEWER, REVIEW_SCORE, block.timestamp);
        sciChain.reviewProposal(proposalCounter, REVIEW_SCORE);
        vm.stopPrank();

        (,,,uint256 expectedReviewScore,,,,) = sciChain.proposals(1);

        assertEq(expectedReviewScore, REVIEW_SCORE);
    }

    function test_multiple_users_can_review() public listProposal addReviewer {
      
        uint256 expectedReviewerCount = sciChain.reviewerCount();
        assert(expectedReviewerCount == reviewers.length);

        uint256 proposalCounter = sciChain.proposalCounter();
        for (uint i = 0; i < reviewers.length; i++) {
            vm.prank(reviewers[i]);
            sciChain.reviewProposal(proposalCounter, REVIEW_SCORE);
        }
         (,,,uint256 reviewScore,,,,) = sciChain.proposals(proposalCounter);
        uint256 expectedReviewScore = reviewers.length * REVIEW_SCORE;
        assertEq(expectedReviewScore, reviewScore);
        // assertEq(a, b);
    }

    function test_reviewer_cant_review_multiple_times() public listProposal addReviewer {
        uint256 proposalCounter = sciChain.proposalCounter();
        for (uint i = 0; i < reviewers.length; i++) {
            vm.prank(reviewers[i]);
            sciChain.reviewProposal(proposalCounter, REVIEW_SCORE);
        }
         for (uint i = 0; i < reviewers.length; i++) {
            vm.prank(reviewers[i]);
            vm.expectRevert("SciChain: reviewer has reviewed proposal");
            sciChain.reviewProposal(proposalCounter, REVIEW_SCORE);
        }

    }

    function testPublishProposal() public listProposal addReviewer {
        // expected revert 
        uint256 proposalCounter = sciChain.proposalCounter();
        vm.prank(address(0x1234));
        vm.expectRevert("SciChain: caller is not a publisher");
        sciChain.publishProposal(proposalCounter);

        vm.startPrank(_initAdmin);
        vm.expectRevert("SciChain: proposal not reviewed");
        sciChain.publishProposal(proposalCounter + 1);
        vm.stopPrank();
        
        // expected revert
        vm.prank(REVIEWER);
        sciChain.reviewProposal(proposalCounter, REVIEW_SCORE);
        vm.prank(_initAdmin);
        vm.expectRevert("SciChain: proposal review score too low");
        sciChain.publishProposal(proposalCounter);

        // success rate
        for (uint i = 1; i < reviewers.length; i++) {
            vm.prank(reviewers[i]);
            sciChain.reviewProposal(proposalCounter, AVERAGE_REVIEW_SCORE);
        }

        (
        ,
        ,
        ,
        ,
        ,
        uint256 averageScore,
        ,
         ) = sciChain.proposals(proposalCounter);
        console.log("Average Score %d", averageScore);
        vm.startPrank(_initAdmin);
        vm.expectEmit(true, true, false, false, address(sciChain));
        emit ProposalPublished(proposalCounter, _initAdmin, block.timestamp);
        sciChain.publishProposal(proposalCounter);
       
    }
}