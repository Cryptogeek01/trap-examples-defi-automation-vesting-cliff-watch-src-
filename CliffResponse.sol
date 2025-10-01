// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

contract CliffResponse {
    mapping(address => bool) public flaggedContracts;
    event ContractFlagged(address indexed vestingContract, uint256 unlockTime);

    function respondToCliff(address vestingContract, uint256 unlockTime) external {
        flaggedContracts[vestingContract] = true;
        emit ContractFlagged(vestingContract, unlockTime);
    }

    function isFlagged(address vestingContract) external view returns (bool) {
        return flaggedContracts[vestingContract];
    }
}
