// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import {Ownable} from "@openzeppelin/contracts/access/Ownable.sol";

contract CliffResponse is Ownable {
    mapping(address => bool) public allowlist;

    event CliffTriggered(address indexed vestingContract, uint256 unlockTime, uint256 timestamp);
    event ResponseFailed(address indexed vestingContract, uint256 unlockTime, string reason);

    constructor(address initialOwner) Ownable(initialOwner) {}

    modifier onlyAllowed() {
        require(allowlist[msg.sender], "Caller not allowed");
        _;
    }

    function updateAllowlist(address caller, bool allowed) external onlyOwner {
        allowlist[caller] = allowed;
    }

    function respondToCliff(address vestingContract, uint256 unlockTime) external onlyAllowed {
        if (block.timestamp < unlockTime) {
            emit ResponseFailed(vestingContract, unlockTime, "Cliff not reached");
            revert("Cliff not reached");
        }
        if (vestingContract == address(0)) {
            emit ResponseFailed(vestingContract, unlockTime, "Invalid vesting contract");
            revert("Invalid vesting contract");
        }

        emit CliffTriggered(vestingContract, unlockTime, block.timestamp);

        // Add vesting logic (e.g., call vestingContract.release())
    }
}
