// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import "forge-std/Script.sol";
import {Raffle} from "../src/Raffle.sol";

/// @notice Deploys the Raffle contract
contract Deploy is Script {
    function run() external returns (Raffle deployed) {
        uint256 key = vm.envUint("PRIVATE_KEY");
        uint256 entranceFee = 0.01 ether;   // keep this in sync with your tests/UI
        uint256 interval = 30;              // seconds

        vm.startBroadcast(key);
        deployed = new Raffle(entranceFee, interval);
        vm.stopBroadcast();

        console2.log("Raffle deployed at:", address(deployed));
    }
}
