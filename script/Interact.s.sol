// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import "forge-std/Script.sol";
import {Raffle} from "../src/Raffle.sol";

/// @notice Interacts with a deployed Raffle contract
contract Interact is Script {
    /// @dev Enter the raffle with a specific value (in wei).
    /// forge script script/Interact.s.sol:Interact \
    ///  --rpc-url $RPC_URL --private-key $PRIVATE_KEY --broadcast \
    ///  --sig "enter(address,uint256)" 0xYourRaffle 10000000000000000
   
        // Get some private keys from env or hardcode from Anvil (ONLY FOR LOCAL TESTING!)
       function enterMultiple(address raffleAddr, uint256 amountWei) external {
    uint256[3] memory keys = [
        vm.envUint("PRIVATE_KEY_1"),
        vm.envUint("PRIVATE_KEY_2"),
        vm.envUint("PRIVATE_KEY_3")
    ];

    for (uint256 i = 0; i < keys.length; i++) {
        vm.startBroadcast(keys[i]);
        Raffle(raffleAddr).enterRaffle{value: amountWei}();
        vm.stopBroadcast();
    }
}

    /// @dev Pick a winner (anyone can call once interval & conditions are met).
    /// forge script script/Interact.s.sol:Interact \
    ///  --rpc-url $RPC_URL --private-key $PRIVATE_KEY --broadcast \
    ///  --sig "pick(address)" 0xYourRaffle
    function pick(address raffleAddr) external {
        Raffle r = Raffle(raffleAddr);
        uint256 key = vm.envUint("PRIVATE_KEY_1");
        vm.startBroadcast(key);
        Raffle(raffleAddr).pickWinner();
        vm.stopBroadcast();
        console2.log("pickWinner() called on:", raffleAddr);
        console2.log("Winner picked:", r.getRecentWinner());
    }

    /// @dev Read-only helper to print state.
    /// forge script script/Interact.s.sol:Interact \
    ///  --rpc-url $RPC_URL \
    ///  --sig "show(address)" 0xYourRaffle
    function show(address raffleAddr) external view {
        Raffle r = Raffle(raffleAddr);
        (bool upkeep,) = r.checkUpkeep("");
        console2.log("--- Raffle State ---");
        console2.log("address(this).balance:", address(r).balance);
        console2.log("players:", r.getPlayersLength());
        console2.log("recentWinner:", r.getRecentWinner());
        console2.log("state (0=OPEN,1=CALCULATING):", uint256(r.getRaffleState()));
        console2.log("interval (s):", r.getInterval());
        console2.log("upkeepNeeded:", upkeep);
    }
}
