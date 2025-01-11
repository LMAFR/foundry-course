//SPDX-License-Identifier: MIT

pragma solidity 0.8.19;


/**
 * @author  LMAFR
 * @title   A sample Raffle contract
 * @dev     Implements Chainlink VRFv2.5
 * @notice  This contract is for creating a sample raffle
 */
contract Raffle {
    uint256 private immutable i_entranceFee;

    constructor(uint256 entranceFee) {
        i_entranceFee = entranceFee;
    }

    function enterRaffle() public payable {

    }

    function pickWinner() public {

    }

    /** Getter functions */
    function getEntraceFee() external view returns (uint256) {
        return i_entranceFee;
    }
}