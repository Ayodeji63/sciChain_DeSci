// SPDX-License-Identifier: MIT

pragma solidity ^0.8.18;

import "forge-std/Test.sol";
import "@bnb-chain/greenfield-contracts/contracts/interface/IGroupHub.sol";
import "../src/SciChain.sol";
import {ISciChain} from "../src/Interfaces/ISciChain.sol";

interface IERC721GROUP {
    function mint(address to, uint256 tokenId) external;
}

contract SciChainTest is Test {

    event ProposalListed(uint256 indexed proposalId, address indexed owner, uint256 indexed groupId, uint256 timestamp);

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

    string public constant title = "Biomedical Research";
    string public constant description = "Biomedical Research description";
    function setUp() public {
        sciChain = new SciChain();
        sciChain.initialize(_initAdmin, _fundWallet, _feeRate, _callbackGasLimit, _failureHandleStrategy);
        groupHub = sciChain.GROUP_HUB_D();
        groupToken = sciChain.GROUP_TOKEN();
        crossChain = sciChain.CROSS_CHAIN();
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
        vm.expectRevert("MarketPlace: only group owner");
        sciChain.listProposal(title, description, tokenId);
        vm.stopPrank();

        // success case
        // IGroupHub(groupHub).grant(address(sciChain), 4, 0);
        vm.expectEmit(true, true, true, false, address(sciChain));
        emit ProposalListed(1, address(this), tokenId, block.timestamp);
        sciChain.listProposal(title, description, tokenId);
    }

    function testDelist(uint256 tokenId) public {
        
    }
}