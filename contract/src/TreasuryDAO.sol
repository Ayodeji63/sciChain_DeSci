// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;
import {Ownable} from "@openzeppelin/contracts/access/Ownable.sol";
import {SciChain} from "./SciChain.sol";

contract TreasuryDAO is Ownable {
    mapping(address => uint256) public balances;
    uint8 public constant PUBLISHED_STATUS = 2;
    SciChain public immutable sciChain;


    event Deposit(address indexed depositor, uint256 amount);
    event Withdrawal(address indexed withdrawer, uint256 amount);

    constructor(address _sciChainAddress) {
        sciChain = SciChain(_sciChainAddress);
    }

    function fundProject(address recipient, uint256 proposalId, uint256 _amount) onlyOwner payable public {
        require(uint8(sciChain.getProposalStatus(proposalId)) == uint8(PUBLISHED_STATUS), "ProjectFunding: Cant Fund This Project");
        require(_amount <= address(this).balance, "ProjectFunding: Invalid amount");
        (bool success, ) = payable(recipient).call{value: _amount}("");
        require(success, "ProjectFunding: Failed To Send Funds");
    }
    function deposit() external payable {
        require(msg.value > 0, "TreasuryDAO: Deposit amount must be greater than 0");

        balances[msg.sender] += msg.value;
        emit Deposit(msg.sender, msg.value);
    }

    function withdraw(uint256 amount) external {
        require(amount > 0, "TreasuryDAO: Withdrawal amount must be greater than 0");
        require(balances[msg.sender] >= amount, "TreasuryDAO: Insufficient balance");

        balances[msg.sender] -= amount;
        payable(msg.sender).transfer(amount);
        emit Withdrawal(msg.sender, amount);
    }

    function withdrawAll() external {
        uint256 amount = balances[msg.sender];
        require(amount > 0, "TreasuryDAO: No funds to withdraw");

        balances[msg.sender] = 0;
        payable(msg.sender).transfer(amount);
        emit Withdrawal(msg.sender, amount);
    }

    function getBalance() external view returns (uint256) {
        return balances[msg.sender];
    }


    receive() external payable {
        // Fallback function to accept Ether
        if (msg.value > 0) {
            balances[msg.sender] += msg.value;
            emit Deposit(msg.sender, msg.value);
        }
    }
}
