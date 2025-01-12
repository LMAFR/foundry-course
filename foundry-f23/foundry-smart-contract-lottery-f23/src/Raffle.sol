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


/**
 * @author  LMAFR
 * @title   A sample Raffle contract
 * @dev     Implements Chainlink VRFv2.5
 * @notice  This contract is for creating a sample raffle
 */
contract Raffle {

    /** Errors */
    error Raffle__SendMoreToEnterRaffle();

    uint256 private immutable i_entranceFee;

    constructor(uint256 entranceFee) {
        i_entranceFee = entranceFee;
    }

    function enterRaffle() public payable {
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
    }

    function pickWinner() public {

    }

    /** Getter functions */
    function getEntraceFee() external view returns (uint256) {
        return i_entranceFee;
    }
}