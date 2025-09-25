// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

/// @title VestingMock
/// @notice Simple mock with configurable cliff() and beneficiary() so you can simulate events in Remix.
contract VestingMock {
    uint256 private _cliff;
    address private _beneficiary;

    event CliffSet(uint256 cliff);
    event BeneficiarySet(address beneficiary);

    constructor(uint256 cliff_, address beneficiary_) {
        cliff = cliff;
        beneficiary = beneficiary;
    }

    function cliff() external view returns (uint256) {
        return _cliff;
    }

    function beneficiary() external view returns (address) {
        return _beneficiary;
    }

    // helpers for testing
    function setCliff(uint256 c) external {
        _cliff = c;
        emit CliffSet(c);
    }

    function setBeneficiary(address b) external {
        _beneficiary = b;
        emit BeneficiarySet(b);
    }
}
