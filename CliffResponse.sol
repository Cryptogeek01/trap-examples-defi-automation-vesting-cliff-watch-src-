// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

/// @title CliffResponse
/// @notice Small response contract: Drosera operators call this when the trap triggers.
contract CliffResponse {
    event CliffTriggered(
        address vestingContract,
        address beneficiary,
        uint256 cliffTimestamp,
        uint256 currentTime,
        bool triggered,
        address reporter
    );

    function respondWithCliff(
        address vestingContract,
        address beneficiary,
        uint256 cliffTimestamp,
        uint256 currentTime,
        bool triggered
    ) external {
        emit CliffTriggered(vestingContract, beneficiary, cliffTimestamp, currentTime, triggered, msg.sender);
    }
}
