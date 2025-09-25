// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import {ITrap} from "drosera-contracts/interfaces/ITrap.sol";

interface IVesting {
    function cliff() external view returns (uint256);
    function beneficiary() external view returns (address);
}

contract VestingCliffTrap is ITrap {
    address public owner;

    // monitored vesting contract
    address public vestingContract;

    // cached values (used by collect)
    uint256 public cliffTimestamp;
    address public beneficiary;

    event ConfigSet(address indexed setter, address vestingContract, uint256 cliffTimestamp, address beneficiary);
    event CliffDetected(address vestingContract, address beneficiary, uint256 cliffTimestamp, uint256 currentTime);

    constructor() {
        owner = msg.sender;
    }

    modifier onlyOwner() {
        require(msg.sender == owner, "only owner");
        _;
    }

    /// @notice Owner sets the vesting contract to watch. This reads cliff() & beneficiary() if available.
    function setVestingContract(address _vesting) external onlyOwner {
        vestingContract = _vesting;
        // try read cliff & beneficiary
        try IVesting(_vesting).cliff() returns (uint256 c) {
            cliffTimestamp = c;
        } catch {
            cliffTimestamp = 0;
        }
        try IVesting(_vesting).beneficiary() returns (address b) {
            beneficiary = b;
        } catch {
            beneficiary = address(0);
        }
        emit ConfigSet(msg.sender, vestingContract, cliffTimestamp, beneficiary);
    }

    // --- CollectOutput ---
    struct CollectOutput {
        address vestingContract;
        uint256 cliffTimestamp;
        uint256 currentTime;
        address beneficiary;
    }

    /// @notice collect current vesting info (called by operators every block)
    function collect() external view returns (bytes memory) {
        uint256 c = cliffTimestamp;
        address b = beneficiary;

        if (vestingContract != address(0)) {
            try IVesting(vestingContract).cliff() returns (uint256 c2) {
                c = c2;
            } catch {}
            try IVesting(vestingContract).beneficiary() returns (address b2) {
                b = b2;
            } catch {}
        }

        CollectOutput memory out = CollectOutput({
            vestingContract: vestingContract,
            cliffTimestamp: c,
            currentTime: block.timestamp,
            beneficiary: b
        });

        return abi.encode(out);
    }

    /// @notice shouldRespond: returns true when cliff has been reached (currentTime >= cliff)
    /// @dev Drosera will pass an array of collected samples; we read latest (data[0]).
    function shouldRespond(bytes[] calldata data) external pure override returns (bool, bytes memory) {
        if (data.length == 0) return (false, "");

        CollectOutput memory latest = abi.decode(data[0], (CollectOutput));

        bool triggered = (latest.cliffTimestamp > 0 && latest.currentTime >= latest.cliffTimestamp);

        // response payload: vestingContract, beneficiary, cliffTimestamp, currentTime, triggered
        bytes memory resp = abi.encode(latest.vestingContract, latest.beneficiary, latest.cliffTimestamp, latest.currentTime, triggered);

        return (triggered, resp);
    }
}
