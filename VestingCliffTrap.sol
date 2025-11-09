// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import {ITrap} from "drosera-contracts/interfaces/ITrap.sol";

interface IVesting {
 function cliff() external view returns(uint256);
}

interface IVestingCliffConfig {
    function getConfig(address trap) external view returns (address, uint256, address);
}

contract VestingCliffTrap is ITrap {
      address public constant CONFIG = 0x0000000000000000000000000000000000000000; 

    /// Collect data (Drosera-compatible)
    function collect() external view override returns (bytes memory) {
        (address vestingContract, uint256 cliffTimestamp, address responseContract) = IVestingCliffConfig(CONFIG).getConfig(address(this));

        //Validate configuration
       (bool cliffPassed, address vesting, uint256 unlockTime) = abi.decode(data[0], (bool, address, uint256));
        (, , address responseContract) = IVestingCliffConfig(configContract).getConfig(address(this));

         if (vestingContract == address(0) || responseContract == address(0)) {
            return abi.encode(false, address(0), uint256(0));
        }

        //Read cliff timestamp from vesting contract
        uint256 cliffTimestamp = IVesting(vestingContract).cliff();
        bool cliffPassed = block.timestamp >= cliffTimestamp;
        return abi.encode(cliffPassed, vestingContract, cliffTimestamp);
    }

    /// Decide if response is needed
  function shouldRespond(bytes[] calldata data) external pure override returns (bool, bytes memory) {
    if (data.length == 0 || data[0].length == 0) {
        return (false, bytes(""));
    }

    (bool cliffPassed, address vesting, uint256 unlockTime) = abi.decode(data[0], (bool, address, uint256));

    if (!cliffPassed || vesting == address(0)) {
        return (false, bytes(""));
    }

    return (true, abi.encode(vesting, unlockTime));
}

}
