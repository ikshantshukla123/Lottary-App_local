// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import  "forge-std/Test.sol";
import {Raffle} from "../src/Raffle.sol";

contract RaffleTest is Test {
    Raffle raffle;
    uint256 entranceFee = 0.01 ether;
    uint256 interval = 30; // seconds

    address PLAYER = makeAddr("player");
    address PLAYER2 = makeAddr("player2");

    function setUp() public {
        raffle = new Raffle(entranceFee, interval);
        vm.deal(PLAYER, 10 ether);
        vm.deal(PLAYER2, 10 ether);
    }

    function testConstructorInitializesCorrectly() public view {
        assertEq(uint256(raffle.getRaffleState()), 0); // OPEN
        assertEq(raffle.getInterval(), interval);
        assertEq(raffle.getEntranceFee(), entranceFee);
    }

    function testEnterRequiresEnoughEth() public {
        vm.prank(PLAYER);
        vm.expectRevert(Raffle.Raffle_SendMoreToEnterRaffle.selector);
        raffle.enterRaffle{value: 0}();
    }

    function testEnterStoresPlayerAndEmitsEvent() public {
        vm.prank(PLAYER);
        vm.expectEmit(true, false, false, false);
        emit Raffle.RaffleEnter(PLAYER);
        raffle.enterRaffle{value: entranceFee}();
        assertEq(raffle.getPlayersLength(), 1);
        assertEq(raffle.getPlayer(0), PLAYER);
    }

    function testCantEnterWhenCalculating() public {
        // Fill one player & fast-forward time so upkeep is true
        vm.prank(PLAYER);
        raffle.enterRaffle{value: entranceFee}();
        vm.warp(block.timestamp + interval + 1);
        vm.roll(block.number + 1);

        // Trigger calculation state
        vm.prank(address(1));
        raffle.pickWinner();

        vm.expectRevert(Raffle.Raffle_RaffleNotOpen.selector);
        vm.prank(PLAYER2);
        raffle.enterRaffle{value: entranceFee}();
    }

    function testPickWinnerRevertsIfUpkeepNotNeeded() public {
        // No players / not enough time etc.
        vm.expectRevert();
        raffle.pickWinner();
    }

    function testPickWinnerWorksAndResets() public {
        // arrange
        vm.prank(PLAYER);
        raffle.enterRaffle{value: entranceFee}();
        vm.prank(PLAYER2);
        raffle.enterRaffle{value: entranceFee}();
       

        vm.warp(block.timestamp + interval + 1);
        vm.roll(block.number + 1);

        // act
        vm.prank(PLAYER); // anyone can call
        raffle.pickWinner();
    }
}
