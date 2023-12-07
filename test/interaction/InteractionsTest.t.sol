// SPDX-License-Identifier: MIT
pragma solidity ^0.8.23;

import {Test, console} from "forge-std/Test.sol";
import {FundMe} from "../../src/FundMe.sol";
import {DeployFundMe} from "../../script/DeployFundMe.s.sol";
import {FundFundMe, WithdrawFundMe} from "../../script/Interactions.s.sol";

contract InteractionsTest is Test {
    // constructor() {

    // }
    FundMe fundMe;
    address SENDER = makeAddr("jaunepr");
    uint256 constant SEND_VALUE = 1 ether;
    uint256 constant SENDER_BALANCE = 10 ether;

    // uint256 constant FUNDERS_INDEX = 0;

    function setUp() external {
        // i -> FundMeTest -> FundMe
        // fundMe = new FundMe(0x694AA1769357215DE4FAC081bf1f309aDC325306);
        //just call deploy function
        // i -> FundMeTest -> DeployFundMe -> FundMe
        DeployFundMe deployFundMe = new DeployFundMe();
        fundMe = deployFundMe.run();
        vm.deal(SENDER, SENDER_BALANCE);
    }

    function testUserCanFundInteraction() public {
        FundFundMe fundFundMe = new FundFundMe();
        fundFundMe.fundFundMe(address(fundMe));

        WithdrawFundMe withdrawFundMe = new WithdrawFundMe();
        withdrawFundMe.withdrawFundMe(address(fundMe));
        assert(address(fundMe).balance == 0);
    }
}
