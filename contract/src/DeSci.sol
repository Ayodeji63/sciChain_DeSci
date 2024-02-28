// SPDX-License-Identifier: GPL-3.0-or-later
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/access/AccessControl.sol";
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";
import "@openzeppelin/contracts-upgradeable/utils/structs/EnumerableSetUpgradeable.sol";

contract DeSci is ReentrancyGuard, AccessControl {
    using EnumerableSetUpgradeable for EnumerableSetUpgradeable.UintSet;

    bytes32 public constant PROPOSAL_OWNER_ROLE = keccak256("PROPOSAL_OWNER_ROLE");
    bytes32 public constant REVIEWER_ROLE = keccak256("REVIEWER_ROLE");
    bytes32 public constant PUBLISHER_ROLE = keccak256("PUBLISHER_ROLE");
    bytes32 public constant VOTER_ROLE = keccak256("VOTER_ROLE");

    uint256 public constant MINIMUM_REVIEW_SCORE = 1; // Adjust as needed
    uint256 public constant MINIMUM_VOTE_POWER = 1; // Adjust as needed

    enum ProposalStatus { Listed, Reviewed, Published, Voted, Accepted }

    struct Proposal {
        string title;
        string description;
        address owner;
        ProposalStatus status;
        uint256 reviewScore;
        uint256 voteCount;
        uint256 timestamp;
    }

    mapping(uint256 => Proposal) public proposals;
    mapping(address => EnumerableSetUpgradeable.UintSet) private userProposals;

    uint256 public proposalCounter;

    event ProposalListed(uint256 indexed proposalId, address indexed owner, string title, uint256 timestamp);
    event ProposalReviewed(uint256 indexed proposalId, address indexed reviewer, uint256 reviewScore, uint256 timestamp);
    event ProposalPublished(uint256 indexed proposalId, address indexed publisher, uint256 timestamp);
    event ProposalVoted(uint256 indexed proposalId, address indexed voter, uint256 votePower, uint256 timestamp);
    event ProposalAccepted(uint256 indexed proposalId, uint256 timestamp);

    constructor() {
        _setupRole(DEFAULT_ADMIN_ROLE, msg.sender);
        _setupRole(PROPOSAL_OWNER_ROLE, msg.sender);
        _setupRole(REVIEWER_ROLE, msg.sender);
        _setupRole(PUBLISHER_ROLE, msg.sender);
        _setupRole(VOTER_ROLE, msg.sender);
    }

    modifier onlyProposalOwner(uint256 proposalId) {
        require(hasRole(PROPOSAL_OWNER_ROLE, proposals[proposalId].owner), "DeSci: caller is not the proposal owner");
        _;
    }

    modifier onlyReviewer() {
        require(hasRole(REVIEWER_ROLE, msg.sender), "DeSci: caller is not a reviewer");
        _;
    }

    modifier onlyPublisher() {
        require(hasRole(PUBLISHER_ROLE, msg.sender), "DeSci: caller is not a publisher");
        _;
    }

    modifier onlyVoter() {
        require(hasRole(VOTER_ROLE, msg.sender), "DeSci: caller is not a voter");
        _;
    }

    function listProposal(string memory title, string memory description) external returns (uint256) {
        proposalCounter++;
        Proposal storage newProposal = proposals[proposalCounter];
        newProposal.title = title;
        newProposal.description = description;
        newProposal.owner = msg.sender;
        newProposal.status = ProposalStatus.Listed;
        newProposal.timestamp = block.timestamp;

        userProposals[msg.sender].add(proposalCounter);

        emit ProposalListed(proposalCounter, msg.sender, title, block.timestamp);

        return proposalCounter;
    }

    function reviewProposal(uint256 proposalId, uint256 reviewScore) external onlyReviewer {
        require(proposals[proposalId].status == ProposalStatus.Listed, "DeSci: proposal not listed");
        require(reviewScore >= MINIMUM_REVIEW_SCORE, "DeSci: review score too low");

        proposals[proposalId].status = ProposalStatus.Reviewed;
        proposals[proposalId].reviewScore = reviewScore;

        emit ProposalReviewed(proposalId, msg.sender, reviewScore, block.timestamp);
    }

    function publishProposal(uint256 proposalId) external onlyPublisher {
        require(proposals[proposalId].status == ProposalStatus.Reviewed, "DeSci: proposal not reviewed");

        proposals[proposalId].status = ProposalStatus.Published;

        emit ProposalPublished(proposalId, msg.sender, block.timestamp);
    }

    function voteOnProposal(uint256 proposalId, uint256 votePower) external onlyVoter {
        require(proposals[proposalId].status == ProposalStatus.Published, "DeSci: proposal not published");
        require(votePower >= MINIMUM_VOTE_POWER, "DeSci: vote power too low");

        proposals[proposalId].voteCount += votePower;

        emit ProposalVoted(proposalId, msg.sender, votePower, block.timestamp);
    }

    function acceptProposal(uint256 proposalId) external onlyPublisher {
        require(proposals[proposalId].status == ProposalStatus.Published, "DeSci: proposal not published");

        proposals[proposalId].status = ProposalStatus.Accepted;

        emit ProposalAccepted(proposalId, block.timestamp);
    }

    function getUserProposals(address user) external view returns (uint256[] memory) {
        uint256[] memory userProposalIds = new uint256[](userProposals[user].length());
        for (uint256 i = 0; i < userProposals[user].length(); i++) {
            userProposalIds[i] = userProposals[user].at(i);
        }
        return userProposalIds;
    }
}
