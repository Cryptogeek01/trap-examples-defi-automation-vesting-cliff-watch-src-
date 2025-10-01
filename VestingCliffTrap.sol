// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import {ITrap} from "drosera-contracts/interfaces/ITrap.sol";

interface ICliffResponse {
    function respondToCliff(address vestingContract, uint256 unlockTime) external;
}

contract VestingCliffTrap is ITrap {
    address public vestingContract;
    uint256 public cliffTimestamp;
    address public responseContract;

    event CliffTriggered(address indexed vesting, uint256 unlockTime, uint256 timestamp);

    constructor(address _vestingContract, uint256 _cliffTimestamp, address _responseContract) {
        vestingContract = _vestingContract;
        cliffTimestamp = _cliffTimestamp;
        responseContract = _responseContract;
    }

    /// Collect data (Drosera-compatible)
    function collect() external view override returns (bytes memory) {
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
        require(block.timestamp >= unlockTime, "Cliff not reached");
        emit CliffTriggered(vesting, unlockTime, block.timestamp);

        // Call the response contract
        ICliffResponse(responseContract).respondToCliff(vesting, unlockTime);
    }
}
