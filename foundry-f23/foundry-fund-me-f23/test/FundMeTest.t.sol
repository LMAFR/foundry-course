//SPDX-License-Identifier: MIT

pragma solidity ^0.8.18;

import {Test, console} from "forge-std/Test.sol";
import {FundMe} from "../src/FundMe.sol";
import {DeployFundMe} from "../script/DeployFundMe.s.sol";
// import {DSTest} from "ds-test/test.sol";

contract FundMeTest is Test {
    FundMe fundMe;

    // makeAddr creates a new address for our tests. It comes from forge-std
    address USER = makeAddr("user");
    // This "ether" do not work in solidity, but it does in tests.
    uint256 constant SEND_VALUE = 0.1 ether; //1e17
    // We have to add some money for this new address so it can fund our contract later
    uint256 constant STARTING_BALANCE = 10 ether;

    // Deploy our contract into this test contract
    // setUp() function always runs first than other test functions we will build below
    function setUp() external {
        // Variable fundMe will be a new instance of FundMe contract and it will be of type FundMe:
        // Here we are calling FundMeTest and then telling it to call to FundMe, so we are the sender of FundMeTest and FundMeTest is
        // the sender of FundMe() contract.
        DeployFundMe deployFundMe = new DeployFundMe();
        fundMe = deployFundMe.run();
        // Give some money to our new address:
        vm.deal(USER, STARTING_BALANCE);
    }

    function testMinimumDollarIsFive() public {
        // console.log(fundMe.MINIMUM_USD());
        assertEq(fundMe.MINIMUM_USD(), 5e18);
    }

    function testOwnerIsMsgSender() public {
        // assertEq(fundMe.i_owner, msg.sender)
        // address(this) is the address of FundMeTest contracts
        // After refactoring the code, msg.sender is now equal to fundMe.i_owner, instead of address(this). This is due to
        // vm.broadcast, but we will go deeper into this in the future, not now.
        assertEq(fundMe.getOwner(), msg.sender);
    }

    function testPriceFeedVersionIsAccurate() public {
        uint256 version = fundMe.getVersion();
        assertEq(version, 4);
    }

    function testFundFailsWithoutEnoughEth() public {
        vm.expectRevert();
        // We call fund() function with no arguments, so we will be trying to fund 0 ETH, which would be less than minimum, so it will
        // fail and transaction will revert, so this test pass
        fundMe.fund();
    }

    function testFundUpdatesFundedDataStructure() public {
        // Prank cheatcode let us define who the msg.sender will be
        vm.prank(USER); // The next transaction will be sent by USER
        // Pay attention to the line below. Money is sent as an argument between {}. It is not part of the natural arguments of
        // function fund().
        fundMe.fund{value: SEND_VALUE}(); // Send 0.1eth (> 5 USD)

        uint256 amountFunded = fundMe.getAddressToAmountFunded(USER);
        assertEq(amountFunded, SEND_VALUE);
    }

    // If we see a part of the code in tests is going to be repeated with no reason, we can create a modifier, so we do not have
    // to be pasting that code everywhere. See below:
    modifier funded() {
        vm.prank(USER);
        fundMe.fund{value: SEND_VALUE}();
        _;
    }

    // Each time a test is going to be run, setUp() function restart, so USER will be in index 0 even is previous function use USER
    function testAddFunderToArrayOfFunders() public funded {
        address funder = fundMe.getFunder(0);
        assertEq(funder, USER);
    }

    function testOnlyOwnerCanWithdraw() public funded {
        // vm functions apply to the next non-vm function, so in the two lines below the order is not important.
        // In the same way, as we already applied USER to function fund in the previous lines, we have to call it again.
        vm.expectRevert();
        vm.prank(USER);
        fundMe.withdraw();
    }

    function testWithdrawWithASingleFunder() public funded {
        // Arrange
        uint256 startingOwnerBalance = fundMe.getOwner().balance;
        uint256 startingFundMeBalance = address(fundMe).balance;
        // Act
        vm.prank(fundMe.getOwner());
        fundMe.withdraw();
        // Assert
        uint256 endingOwnerBalance = fundMe.getOwner().balance;
        uint256 endingFundMeBalance = address(fundMe).balance;
        assertEq(
            endingOwnerBalance,
            startingOwnerBalance + startingFundMeBalance
        );
        assertEq(endingFundMeBalance, 0);
    }

    function testWithdrawWithASeveralFunders() public funded {
        // Arrange
        // We will use uint160 because those are the integers we can use to create a address using address(n). It is that way because
        // that 160 is related to the number of bytes that an account has.
        uint160 numberOfFunders = 10;
        // It is not recommended to start 0 because usually are sanity tests and other issues that can make your test fail if you
        // operate on address(0) (we are going to use this index to create addresses in a for loop)
        uint160 startingFunderIndex = 1;
        for (uint160 i = startingFunderIndex; i < numberOfFunders; i++) {
            // hoax is a function that does, at the same time, vm.deal and vm.prank:
            hoax(address(i), SEND_VALUE);
            fundMe.fund{value: SEND_VALUE}();
        }

        uint256 startingFundMeBalance = address(fundMe).balance;
        uint256 startingOwnerBalance = fundMe.getOwner().balance;
        // Act
        // vm.start/stopPrank are similar to start/stopBroadcast. They will take the USER passed as argument to all the code between
        // start and stop functions. We use it here, but as there is only 1 line of code inside, we could also use vm.prank() directly
        vm.startPrank(fundMe.getOwner());
        fundMe.withdraw();
        vm.stopPrank();
        // Assert
        // We could have used in previous tests, assert instead of assertEq. We will use the following lines as example:
        // After withdraw, fundMe contract should has no money in its balance
        assert(address(fundMe).balance == 0);
        // After withdraw, all the money that we originally had in fundMe, should have passed to the owner of fundMe:
        assert(
            fundMe.getOwner().balance ==
                startingFundMeBalance + startingOwnerBalance
        );
    }
}
