// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

contract VestingCliffConfig {
    // Struct to hold configuration for a trap
    struct TrapConfig {
        address vestingContract;
        uint256 cliffTimestamp;
        address responseContract;
    }

    // Mapping to store configurations by trap ID or address
    mapping(address => TrapConfig) public configs;

    // Owner or authorized entity (e.g., Drosera operator or governance)
    address public owner;

    // Event for configuration updates
    event ConfigUpdated(address indexed trap, address vestingContract, uint256 cliffTimestamp, address responseContract);

    constructor() {
        owner = msg.sender;
    }

    // Modifier for access control
    modifier onlyOwner() {
        require(msg.sender == owner, "Not owner");
        _;
    }

    // Set or update configuration for a trap
    function setConfig(
        address trap,
        address vestingContract,
        uint256 cliffTimestamp,
        address responseContract
    ) external onlyOwner {
        require(trap != address(0), "Invalid trap address");
        require(vestingContract != address(0), "Invalid vesting contract");
        require(responseContract != address(0), "Invalid response contract");
        require(cliffTimestamp > block.timestamp, "Cliff timestamp in past");

        configs[trap] = TrapConfig({
            vestingContract: vestingContract,
            cliffTimestamp: cliffTimestamp,
            responseContract: responseContract
        });

        emit ConfigUpdated(trap, vestingContract, cliffTimestamp, responseContract);
    }

    // Get configuration for a trap
    function getConfig(address trap) external view returns (address, uint256, address) {
        TrapConfig memory config = configs[trap];
        return (config.vestingContract, config.cliffTimestamp, config.responseContract);
    }
}