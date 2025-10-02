// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import {ITrap} from "drosera-contracts/interfaces/ITrap.sol";

interface ICliffResponse {
    function respondToCliff(address vestingContract, uint256 unlockTime) external;
}

interface IVestingCliffConfig {
    function getConfig(address trap) external view returns (address, uint256, address);
}

contract VestingCliffTrap is ITrap {
    address public configContract; // Address of the storage contract

    event CliffTriggered(address indexed vesting, uint256 unlockTime, uint256 timestamp);

    constructor(address _configContract) {
        require(_configContract != address(0), "Invalid config contract");
        configContract = _configContract;
    }

    /// Collect data (Drosera-compatible)
    function collect() external view override returns (bytes memory) {
        (address vestingContract, uint256 cliffTimestamp, ) = IVestingCliffConfig(configContract).getConfig(address(this));
        bool cliffPassed = block.timestamp >= cliffTimestamp;
        return abi.encode(cliffPassed, vestingContract, cliffTimestamp);
    }

    /// Decide if response is needed
    function shouldRespond(bytes[] calldata data) external pure override returns (bool, bytes memory) {
        (bool cliffPassed, address vesting, uint256 unlockTime) = abi.decode(data[0], (bool, address, uint256));
        if (cliffPassed) {
            return (true, abi.encode(vesting, unlockTime));
        }
        return (false, "");
    }

    /// Drosera operators will trigger this
    function executeResponse(address vesting, uint256 unlockTime) external {
        (, uint256 cliffTimestamp, address responseContract) = IVestingCliffConfig(configContract).getConfig(address(this));
        require(block.timestamp >= unlockTime, "Cliff not reached");
        require(unlockTime == cliffTimestamp, "Invalid unlock time");
        emit CliffTriggered(vesting, unlockTime, block.timestamp);

        // Call the response contract
        ICliffResponse(responseContract).respondToCliff(vesting, unlockTime);
    }
}
