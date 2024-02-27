// SPDX-License-Identifier: GPL-3.0-or-later
pragma solidity ^0.8.0;

import "@openzeppelin/contracts-upgradeable/token/ERC721/IERC721Upgradeable.sol";

interface ISciChain is IERC721Upgradeable {
    function initialize(
        address _initAdmin,
        address _fundWallet,
        uint256 _feeRate,
        uint256 _callbackGasLimit,
        uint8 _failureHandleStrategy
    ) external;

    function greenfieldCall(
        uint32 status,
        uint8 resourceType,
        uint8 operationType,
        uint256 resourceId,
        bytes calldata callbackData
    ) external;

    function listProposal(
        string memory title,
        string memory description,
        uint256 groupId
    ) external returns (uint256);

    function reviewProposal(uint256 proposalId, uint256 reviewScore) external;

    function publishProposal(uint256 proposalId) external;

    function getUserProposals(address user) external view returns (uint256[] memory);
}
