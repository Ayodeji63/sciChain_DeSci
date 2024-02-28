// SPDX-License-Identifier: MIT
import {ERC20} from "@openzeppelin/contracts/token/ERC20/ERC20.sol";
pragma solidity ^0.8.18;

contract SciChainToken is ERC20 {
    
    address public immutable i_owner;
    uint256 public constant MINT_FEE = 0.05 ether;

    event SciChainToken_Minted(address indexed owner, uint256 indexed amount);

    constructor(address owner) ERC20("SciChainToken", "SCT") {
        i_owner = owner;
    }

    function mint(uint256 amount) public payable  {
        require(msg.value >= MINT_FEE, "SciChainToken: Invalid value");
        _mint(msg.sender, amount);
        emit SciChainToken_Minted(msg.sender, amount);
    }
}