// SPDX-License-Identifier: GPL-3.0-or-later

// Layout of Contract:
// version
// imports
// interfaces, libraries, contracts
// errors
// Type declarations
// State variables
// Events
// Modifiers
// Functions

// Layout of Functions:
// constructor
// receive function (if exists)
// fallback function (if exists)
// external
// public
// internal
// private
// view & pure functions
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/access/AccessControl.sol";
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";
import "@openzeppelin/contracts-upgradeable/utils/structs/EnumerableSetUpgradeable.sol";
import "@bnb-chain/greenfield-contracts-sdk/GroupApp.sol";
import "@bnb-chain/greenfield-contracts/contracts/interface/IERC721NonTransferable.sol";



contract SciChain is ReentrancyGuard, AccessControl, GroupApp {

    /***********Type Declarations ************/
    enum ProposalStatus { 
    Listed, // 0 
    Reviewed, // 1
    Published // 2 
    }
    using EnumerableSetUpgradeable for EnumerableSetUpgradeable.UintSet;
      struct Proposal {
        string title;
        string description;
        address owner;
        uint256 reviewScore;
        uint256 reviewCount;
        uint256 averageScore;
        uint256 timestamp;
        ProposalStatus status;
    }

    /******************* constant  *********************/

     // greenfield system contracts
    address public constant CROSS_CHAIN_D = 0x57b8A375193b2e9c6481f167BaECF1feEf9F7d4B;
    address public constant GROUP_HUB_D = 0x0Bf7D3Ed3F777D7fB8D65Fb21ba4FBD9F584B579;
    address public constant GROUP_TOKEN = 0x089AFF7964E435eB2C7b296B371078B18E2C9A35;
    address public constant MEMBER_TOKEN = 0x80Dd11998159cbea4BF79650fCc5Da72Ffb51EFc;

    bytes32 public constant PROPOSAL_OWNER_ROLE = keccak256("PROPOSAL_OWNER_ROLE");
    bytes32 public constant REVIEWER_ROLE = keccak256("REVIEWER_ROLE");
    bytes32 public constant PUBLISHER_ROLE = keccak256("PUBLISHER_ROLE");

    uint256 public constant MINIMUM_REVIEW_SCORE = 1; // Adjust as needed
    uint256 public constant MAXIMUM_REVIEW_SCORE = 5;
    uint256 public constant AVERAGE_REVIEW_SCORE = 2;
      // all listed group _ids, ordered by listed time
    EnumerableSetUpgradeable.UintSet private _listedGroups;


    /*********** storage  ********************/
    address public fundWallet;
    uint256 public proposalCounter;
    uint256 public transferGasLimit; // 2300 for now
    uint256 public feeRate; // 10000 = 100%
    uint256 public reviewerCount;

    mapping(uint256 => Proposal) public proposals;
    mapping(address => EnumerableSetUpgradeable.UintSet) private userProposals;

    // group ID => listed date
    mapping(uint256 => uint256) public listedDate;

    // user address => user listed group IDs, ordered by listed time
    mapping(address => EnumerableSetUpgradeable.UintSet) private _userListedGroups;

    mapping (address reviewer=> mapping (uint256 proposalId=> uint256 reviweScore)) reviewerScore;

    mapping (address reviewer => mapping (uint proposalId => bool reviewed)) hasReviewedProposal;


    /********* Events ********/
    event ProposalListed(uint256 indexed proposalId, address indexed owner, uint256 indexed groupId, uint256 timestamp);
    event ProposalReviewed(uint256 indexed proposalId, address indexed reviewer, uint256 reviewScore, uint256 timestamp);
    event ProposalPublished(uint256 indexed proposalId, address indexed publisher, uint256 timestamp);
    event DelistProposal(uint256 indexed proposalId, uint256 indexed groupId);
    event ReviewerAdded();
    event ReviewerRemoved();

    /******** Modifiers **********/
    modifier onlyProposalOwner(uint256 proposalId) {
        require(hasRole(PROPOSAL_OWNER_ROLE, proposals[proposalId].owner), "SciChain: caller is not the proposal owner");
        _;
    }

    modifier onlyReviewers() {
        require(hasRole(REVIEWER_ROLE, msg.sender), "SciChain: caller is not a reviewer");
        _;
    }

    modifier onlyPublisher() {
        require(hasRole(PUBLISHER_ROLE, msg.sender), "SciChain: caller is not a publisher");
        _;
    }

    modifier onlyGroupOwner(uint256 groupId) {
        require(msg.sender == IERC721NonTransferable(GROUP_TOKEN).ownerOf(groupId), "SciChain: only group owner");
        _;
    }

    modifier onlyOwner() {
        require(msg.sender == fundWallet, "SciChain: only owner");
        _;
    }


    /*********** Public Functions **********/
    function initialize(
        address _initAdmin, 
        address _fundWallet, 
        uint256 _feeRate, 
        uint256 _callbackGasLimit, 
        uint8 _failureHandleStrategy
        ) public initializer {
        require(_initAdmin != address(0), "SciChain: invalid admin address");
        _grantRole(DEFAULT_ADMIN_ROLE, _initAdmin);

        transferGasLimit = 2300;
        fundWallet = _fundWallet;
        feeRate = _feeRate;

        __base_app_init_unchained(CROSS_CHAIN_D, _callbackGasLimit, _failureHandleStrategy);
        __group_app_init_unchained(GROUP_HUB_D);

        _setupRole(DEFAULT_ADMIN_ROLE, _initAdmin);
        _setupRole(PROPOSAL_OWNER_ROLE, _initAdmin);
        _setupRole(REVIEWER_ROLE, _initAdmin);
        _setupRole(PUBLISHER_ROLE, _initAdmin);
    }

    /*----------------- external functions -----------------*/

    function greenfieldCall(uint32 status, uint8 resourceType, uint8 operationType, uint256 resourceId, bytes calldata callbackData) external override(GroupApp) {
         require(msg.sender == GROUP_HUB, "MarketPlace: invalid caller");

        if (resourceType == RESOURCE_GROUP) {
            _groupGreenfieldCall(status, operationType, resourceId, callbackData);
        } else {
            revert("SciChain: invalid resource type");
        }
    }

    function listProposal(string memory title ,string memory description, uint256 groupId) external returns (uint256) {
        proposalCounter++;
        Proposal storage newProposal = proposals[proposalCounter];
        newProposal.title = title;
        newProposal.description = description;
        newProposal.owner = msg.sender;
        newProposal.status = ProposalStatus.Listed;
        newProposal.timestamp = block.timestamp;
        

        userProposals[msg.sender].add(proposalCounter);
        listedDate[groupId] = block.timestamp;
        _listedGroups.add(groupId);
        _userListedGroups[msg.sender].add(groupId);
        _setupRole(PROPOSAL_OWNER_ROLE, msg.sender);
        
        emit ProposalListed(proposalCounter, msg.sender, groupId, block.timestamp);

        return proposalCounter;
    }

    function delistProposal(uint256 groupId, uint256 proposalId) onlyGroupOwner(groupId) public {
        require(listedDate[groupId] != 0, "SciChain: not listed");
        delete proposals[proposalId];
        userProposals[msg.sender].remove(proposalId);
        _listedGroups.remove(groupId);
        _userListedGroups[msg.sender].remove(groupId);
        _revokeRole(PROPOSAL_OWNER_ROLE, msg.sender);

        emit DelistProposal(groupId, proposalId);
    }

    function addReviewer(address account) external onlyOwner {
        require(account != address(0), "SciChain: reviewer cannot be address 0");
        require(hasRole(REVIEWER_ROLE, account) == false, "SciChain: account already added");
        _setupRole(REVIEWER_ROLE, account);
        reviewerCount++;
        emit ReviewerAdded();
    }

    function removeReviewer(address account) external onlyOwner {
        require(account != address(0), "SciChain: reviewer cannot be address 0");
        
        _revokeRole(REVIEWER_ROLE, account);

        emit ReviewerRemoved();
    }

    function reviewProposal(uint256 proposalId, uint256 reviewScore) external onlyReviewers {
        require(proposalId <= proposalCounter, "SciChain: proposal not listed");
        require(reviewScore >= MINIMUM_REVIEW_SCORE, "SciChain: review score too low"); 
        require(hasReviewedProposal[msg.sender][proposalId] == false, "SciChain: reviewer has reviewed proposal");
       uint256 previousScore = proposals[proposalId].reviewScore;

        proposals[proposalId].status = ProposalStatus.Reviewed;
        proposals[proposalId].reviewScore = previousScore + reviewScore;
        proposals[proposalId].reviewCount++;
        proposals[proposalId].averageScore = (proposals[proposalId].reviewScore * proposals[proposalId].reviewCount) / proposals[proposalId].reviewCount;
        reviewerScore[msg.sender][proposalId] = reviewScore;
        hasReviewedProposal[msg.sender][proposalId] = true;
        emit ProposalReviewed(proposalId, msg.sender, reviewScore, block.timestamp);
    }

    function publishProposal(uint256 proposalId) external onlyPublisher {
        require(proposals[proposalId].status == ProposalStatus.Reviewed, "SciChain: proposal not reviewed");
        require(proposals[proposalId].averageScore >= reviewerCount * AVERAGE_REVIEW_SCORE, "SciChain: proposal review score too low");

        proposals[proposalId].status = ProposalStatus.Published;

        emit ProposalPublished(proposalId, msg.sender, block.timestamp);
    }

    function getUserProposals(address user) external view returns (uint256[] memory) {
        uint256[] memory userProposalIds = new uint256[](userProposals[user].length());
        for (uint256 i = 0; i < userProposals[user].length(); i++) {
            userProposalIds[i] = userProposals[user].at(i);
        }
        return userProposalIds;
    }

    function getProposalStatus(uint256 proposalId) public view returns(uint8 status) {
        return uint8(proposals[proposalId].status);
    }
}
