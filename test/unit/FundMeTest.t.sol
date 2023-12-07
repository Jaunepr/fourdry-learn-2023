// SPDX-License-Identifier: MIT
pragma solidity ^0.8.23;

import {Test, console} from "forge-std/Test.sol";
import {FundMe} from "../../src/FundMe.sol";
import {DeployFundMe} from "../../script/DeployFundMe.s.sol";

contract FundMeTest is Test {
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

    function testMINMUM_USDisFiveDollar() public {
        console.log("hello, world!");
        assertEq(fundMe.MINIMUM_USD(), 5e18);
    }

    function testOwnerismessagesender() public {
        // FundMe owner is changed; and
        console.log("i_owner:", fundMe.getOwner());
        console.log("msg.sender", msg.sender);
        assertEq(fundMe.getOwner(), msg.sender);
    }

    function testPriceFeedVersionAccurate() public {
        uint256 version = fundMe.getVersion();
        console.log("version:", version);
        assertEq(fundMe.getVersion(), 4);
    }

    //modular deployments
    //modular test

    function testFundNotEnoughEth() public {
        vm.expectRevert(); //next line should revert!
        // assert(This tx fails/reverts)
        fundMe.Fund();
    }

    modifier funded() {
        vm.prank(SENDER);
        fundMe.Fund{value: SEND_VALUE}();
        _;
    }

    function testFundSuccessAndDataUpdate() public {
        vm.prank(SENDER);
        fundMe.Fund{value: SEND_VALUE}();
        uint256 amountFunded = fundMe.getAddressToAmountFunded(SENDER); //括号里是发钱给fundme的地址，此时是当前测试合约地址
        assertEq(amountFunded, SEND_VALUE);
    }

    function testAddFunderToArrayFunders() public {
        vm.prank(SENDER);
        fundMe.Fund{value: SEND_VALUE}();
        address funder = fundMe.getFunders(0);
        assertEq(funder, SENDER);
    }

    function testOnlyOwnerCanWithdraw() public funded {
        vm.expectRevert();
        fundMe.Withdraw();
    }

    function testWithdrawWithASingleFunder() public funded {
        // Arange
        uint256 startingOwnerBalance = fundMe.getOwner().balance;
        uint256 startingFundMeBalance = address(fundMe).balance;
        console.log("owner_balance:", startingOwnerBalance);
        console.log("funded_balance:", startingFundMeBalance);

        //Act
        vm.prank(fundMe.getOwner());
        fundMe.Withdraw();
        //Assert
        uint256 endingOwnerBalance = fundMe.getOwner().balance;
        uint256 endingFundMeBalance = address(fundMe).balance;

        assertEq(endingFundMeBalance, 0);
        assertEq(
            startingOwnerBalance + startingFundMeBalance,
            endingOwnerBalance
        );
    }

    function testWithdrawFromMultiFunders() public funded {
        //Arange
        uint160 funderOfNumbers = 10;
        uint160 funderStartingIndex = 1;
        for (uint160 i = funderStartingIndex; i < funderOfNumbers; i++) {
            //vm.prank(new_address)
            //vm.deal(address, value)
            //address(1),强制转换 but address must be uint160!
            hoax(address(i), SEND_VALUE); //i is new_address, prank + deal
            fundMe.Fund{value: SEND_VALUE}();
        }
        uint256 startingOwnerBalance = fundMe.getOwner().balance;
        uint256 startingFundMeBalance = address(fundMe).balance;
        console.log("startingOwnerBalance:", startingOwnerBalance);
        console.log("startingFundMeBalance:", startingFundMeBalance);
        //Act
        // uint256 startGasLeft = gasleft();
        // vm.txGasPrice(2);
        vm.startPrank(fundMe.getOwner());
        fundMe.Withdraw();
        vm.stopPrank();
        // uint256 endGasLeft = gasleft();
        // uint256 gasUsed = (startGasLeft - endGasLeft) * tx.gasprice;
        // console.log(gasUsed);

        //Assert
        uint256 endingOwnerBalance = fundMe.getOwner().balance;
        uint256 endingFundMeBalance = address(fundMe).balance;

        console.log("endingOwnerBalance :", endingOwnerBalance);
        console.log("endingFundMeBalance :", endingFundMeBalance);
        assert(endingFundMeBalance == 0);
        assert(
            endingOwnerBalance == startingOwnerBalance + startingFundMeBalance
        );
    }

    function testWithdrawFromMultiFundersCheaper() public funded {
        //Arange
        uint160 funderOfNumbers = 10;
        uint160 funderStartingIndex = 1;
        for (uint160 i = funderStartingIndex; i < funderOfNumbers; i++) {
            //vm.prank(new_address)
            //vm.deal(address, value)
            //address(1),强制转换 but address must be uint160!
            hoax(address(i), SEND_VALUE); //i is new_address, prank + deal
            fundMe.Fund{value: SEND_VALUE}();
        }
        uint256 startingOwnerBalance = fundMe.getOwner().balance;
        uint256 startingFundMeBalance = address(fundMe).balance;
        console.log("startingOwnerBalance:", startingOwnerBalance);
        console.log("startingFundMeBalance:", startingFundMeBalance);
        //Act
        // uint256 startGasLeft = gasleft();
        // vm.txGasPrice(2);
        vm.startPrank(fundMe.getOwner());
        fundMe.WithdrawCheaper();
        vm.stopPrank();
        // uint256 endGasLeft = gasleft();
        // uint256 gasUsed = (startGasLeft - endGasLeft) * tx.gasprice;
        // console.log(gasUsed);

        //Assert
        uint256 endingOwnerBalance = fundMe.getOwner().balance;
        uint256 endingFundMeBalance = address(fundMe).balance;

        console.log("endingOwnerBalance :", endingOwnerBalance);
        console.log("endingFundMeBalance :", endingFundMeBalance);
        assert(endingFundMeBalance == 0);
        assert(
            endingOwnerBalance == startingOwnerBalance + startingFundMeBalance
        );
    }
}
