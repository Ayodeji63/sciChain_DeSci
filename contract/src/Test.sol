// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

contract Store {
    uint256 public s_num;

    function store(uint256 num) public {
        s_num = num;
    }
}