// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

contract Raffle {
    //Errors
    error Raffle_SendMoreToEnterRaffle();
    error Raffle_RaffleNotOpen();
    error Raffle__ReentrantCall();
    error Raffle__UpkeepNotNeeded(uint256 currentBalance, uint256 numPlayers, uint256 raffleState);
    error Raffle__TransferFailed();


    //for state
    enum RaffleState {
        OPEN,
        CALCULATING
    }

    //Storage
    uint256 immutable i_entranceFee;
    address payable[] private s_players;
    address payable private s_recentWinner;
    uint256 private s_lastTimeStamp;
    uint256 private immutable i_interval;
    RaffleState private s_state;

    bool private s_locked;

    //Events
    event RaffleEnter(address indexed player);
    event WinnerRequested(uint256 indexed atTimestamp);
    event WinnerPicked(address indexed winner, uint256 prize);
    
    constructor(uint256 entranceFee, uint256 intervalSeconds) {
        i_entranceFee = entranceFee;
        s_state = RaffleState.OPEN;
        s_lastTimeStamp = block.timestamp;
        i_interval = intervalSeconds;
    }

    //modifiers

    modifier nonReentrant() {
        if (s_locked) revert Raffle__ReentrantCall();
        s_locked = true;
        _;
        s_locked = false;
    }

    function enterRaffle() public payable {
        if (s_state != RaffleState.OPEN) {
            revert Raffle_RaffleNotOpen();
        }

        if (msg.value < i_entranceFee) {
            revert Raffle_SendMoreToEnterRaffle();
        }

        s_players.push(payable(msg.sender));
        emit RaffleEnter(msg.sender);
    }

    /// @notice Public pick function (acts like performUpkeep without VRF)

    function pickWinner() external nonReentrant {
        (bool upkeepNeeded,) = checkUpkeep("");

        if (!upkeepNeeded) revert Raffle__UpkeepNotNeeded(address(this).balance, s_players.length, uint256(s_state));

        s_state = RaffleState.CALCULATING;
        emit WinnerRequested(block.timestamp);

        uint256 random =
            uint256(keccak256(abi.encodePacked(block.prevrandao, block.timestamp, s_players.length, address(this))));

        uint256 winnerIndex = random % s_players.length;
        address payable winner = s_players[winnerIndex];
        // effects
        s_recentWinner = winner;
        s_state = RaffleState.OPEN;
        s_players = new address payable[](0);
        s_lastTimeStamp = block.timestamp;

        uint256 prizes = address(this).balance;
        // interaction
        (bool ok,) = winner.call{value: address(this).balance}("");
        if (!ok) revert Raffle__TransferFailed();

        emit WinnerPicked(winner, prizes); // prize emitted as 0 (view on-chain balance diff if needed)
    }

    function checkUpkeep(bytes memory) public view returns (bool upkeepNeeded, bytes memory) {
        bool isOpen = s_state == RaffleState.OPEN;
        bool timePassed = (block.timestamp - s_lastTimeStamp) >= i_interval;
        bool hasPlayers = s_players.length > 0;
        bool hasBalance = address(this).balance > 0;
        upkeepNeeded = isOpen && timePassed && hasPlayers && hasBalance;
        return (upkeepNeeded, bytes(""));
    }

    function getEntranceFee() external view returns (uint256) {
        return i_entranceFee;
    }

    function getInterval() external view returns (uint256) {
        return i_interval;
    }

    function getPlayersLength() external view returns (uint256) {
        return s_players.length;
    }

    function getPlayer(uint256 idx) external view returns (address) {
        return s_players[idx];
    }
    function getPlayers() external view returns (address payable[] memory) {
    return s_players;
}


    function getRecentWinner() external view returns (address) {
        return s_recentWinner;
    }

    function getRaffleState() external view returns (RaffleState) {
        return s_state;
    }

    function getLastTimestamp() external view returns (uint256) {
        return s_lastTimeStamp;
    }
}
