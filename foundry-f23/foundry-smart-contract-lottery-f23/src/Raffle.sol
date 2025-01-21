// Layout of Contract:
// version
// imports
// errors
// interfaces, libraries, contracts
// Type declarations
// State variables
// Events
// Modifiers
// Functions

// Layout of Functions:
// constructor
// receive function (if exists)
// fallback function (if exists)
// external
// public
// internal
// private
// internal & private view & pure functions
// external & public view & pure functions

//SPDX-License-Identifier: MIT

pragma solidity 0.8.19;

import {VRFConsumerBaseV2Plus} from "@chainlink/contracts/src/v0.8/vrf/dev/VRFConsumerBaseV2Plus.sol";
// foundry-f23/foundry-smart-contract-lottery-f23/lib/chainlink-brownie-contracts/contracts/src/v0.8/dev/vrf/VRFConsumerBaseV2Plus.sol
import {VRFV2PlusClient} from "@chainlink/contracts/src/v0.8/vrf/dev/libraries/VRFV2PlusClient.sol";
// lib/chainlink-brownie-contracts/contracts/src/v0.8/vrf/dev/libraries/VRFV2PlusClient.sol

/**
 * @author  LMAFR
 * @title   A sample Raffle contract
 * @dev     Implements Chainlink VRFv2.5
 * @notice  This contract is for creating a sample raffle
 */
contract Raffle is VRFConsumerBaseV2Plus {

    /** Errors */
    error Raffle__SendMoreToEnterRaffle();
    error Raffle__TransferFailed();
    error Raffle__RaffleNotOpen();

    /* Type Variables */
    enum RaffleState {
        OPEN,         // 0
        CALCULATING   // 1
    }

    /* State Variables */
    uint16 private constant REQUEST_CONFIRMATIONS = 3;
    uint32 private constant NUM_WORDS = 1;
    uint256 private immutable i_entranceFee;
    bytes32 private immutable i_keyHash;
    uint256 private immutable i_subscriptionId;
    uint32 private immutable i_callbackGasLimit;
    // Players could be paid, so we do a payable array
    address payable[] s_players; //We use "s_" as convention for variables that are updatable (can change)
    uint256 private s_lastTimeStamp;
    address private s_recentWinner;
    // @dev The duration of the lottery in seconds
    uint256 private immutable i_interval;
    RaffleState private s_raffleState;

    /** Events */
    // We can have up to three indexed parameters in an event (and additional non indexed parameters too)
    event RaffledEntered(address indexed player);
    event WinnerPicked(address indexed winner);

    // VRFConsumerBaseV2Plus has a parameter in the constructor that we are going to inherit in this constructor (see vrfCoordinator in next two lines).
    constructor(uint256 entranceFee, uint256 interval, address vrfCoordinator, bytes32 gasLane, uint256 subscriptionId, uint32 callbackGasLimit ) 
        VRFConsumerBaseV2Plus(vrfCoordinator) {
            i_entranceFee = entranceFee;
            i_interval = interval;
            // When contract is deployed, we take a timestamp "screenshot"
            s_lastTimeStamp = block.timestamp;
            i_keyHash = gasLane;
            i_subscriptionId = subscriptionId;
            i_callbackGasLimit = callbackGasLimit;
            s_raffleState = RaffleState.OPEN;
        }

    function enterRaffle() external payable {
        // The line below is cool and can be found in a lot of legacy code, however...
        // require(msg.value >= i_entranceFee, "Not enough ETH sent");
        // Nowadays we can use custom errors, which spend less gas (we do not add the string), nevertheless...
        // if (msg.value < i_entranceFee) {
        //     revert Raffle__SendMoreToEnterRaffle();
        // }
        // Nowadays too, we can add the error directly in the require, which is much more readable:
        // require(msg.value > i_entranceFee, Raffle__SendMoreToEnterRaffle());
        // But that last feature is available from 0.8.26 solidity version (higher than the one we are using here), requires compile
        // via IR (which takes a lot to compile) and it is still less efficient (theoretically) than 2nd version, so we will use the
        //  2nd version provided in these comments:
        if (msg.value < i_entranceFee) {
            revert Raffle__SendMoreToEnterRaffle();
        }
        if (s_raffleState != RaffleState.OPEN) {
            revert Raffle__RaffleNotOpen();
        }
        // We add payable to msg.sender in the line below because player address should be able to receive ETH:
        s_players.push(payable(msg.sender));
        // Always we update a storage variable, as s_players, we should emit a event (as a thumb rule).
        // This has several benefits:
        // 1. Makes migrations easier
        // 2. Makes front end "indexing" easier (so data can be taken from the blockchain in an easier way)
        emit RaffledEntered(msg.sender);
    }

    function pickWinner() external {
        // Check it enough time has passed
        if ((block.timestamp - s_lastTimeStamp) < i_interval) {
            revert();
        }
        s_raffleState = RaffleState.CALCULATING;
        // We have access to s_vrfCoordinator because our class inherits from VRFConsumerBaseV2Plus
        VRFV2PlusClient.RandomWordsRequest memory request =VRFV2PlusClient.RandomWordsRequest({
            keyHash: i_keyHash,
            subId: i_subscriptionId,
            requestConfirmations: REQUEST_CONFIRMATIONS,
            callbackGasLimit: i_callbackGasLimit,
            numWords: NUM_WORDS,
            extraArgs: VRFV2PlusClient._argsToBytes(VRFV2PlusClient.ExtraArgsV1({nativePayment: true})) // new parameter
            });
        uint256 requestId = s_vrfCoordinator.requestRandomWords(request);
    }

    // CEI: Checks, Effects, Interactions Patterns
    // This pattern (CEI) is used mainly to protect against Reentrancy Attacks
    // fulfillRandomWords function can be found in VRFConsumerBaseV2Plus contract, as an undefined (no code apart from definition) virtual function.
    // That is done to make sure developers who import that contract has to define that function. The "virtual" word in its definition is added
    // to let developer know that he will have to add override{} when he defines this function in his contract.
    // This function will contain the process we want to do after getting the randomWords, in this case, it will be to take the randomNumber from 
    // hexadecimal format of the random word and use it to determine the winner of the Raffle and transfer the money to him.
    function fulfillRandomWords( uint256 requestId, uint256[] calldata randomWords) internal override{
        // Checks
        // Requires (conditionals). Example: the if at the beginning of pickWinner function
        // Start by checks is done because it is the most gas efficient way to code (check if we want to revert before doing anything else)

        // Effect (Internal Contract State changes)
        // randomWords[0] is something like this: 2893040912342809340903, we use module (%) operation, so we get the remainder of the division
        // of that big number divided by the number of players, so the result can be, as maximum, s_players.length-1 and, as minimum, zero (so the result
        // will be one of the index of the list of players, randomly provided by the randomWord returned by RandomWordsRequest function)
        uint256 indexOfWinner = randomWords[0] % s_players.length;
        address payable recentWinner = s_players[indexOfWinner];
        s_recentWinner = recentWinner;
        // Reset Raffle state, list of players (to empty list) and our clock (time when next Raffle starts)
        s_raffleState = RaffleState.OPEN;
        s_players = new address payable[](0); // 0 is the size of the new array
        s_lastTimeStamp = block.timestamp;
        // Emit log with the winner
        emit WinnerPicked(recentWinner);

        // Interactions (External Contract Interactions )
        // Error Management
        (bool success,) = recentWinner.call{value: address(this).balance}("");
        if (!success){
            revert Raffle__TransferFailed();
        }

    }


    /** Getter functions */
    function getEntraceFee() external view returns (uint256) {
        return i_entranceFee;
    }
}