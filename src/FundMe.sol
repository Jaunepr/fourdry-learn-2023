//SPDX-License-Identifier: MIT

pragma solidity ^0.8.18;
//contracts/src/v0.8/shared/interfaces/AggregatorV3Interface.sol
// import {AggregatorV3Interface} from "@chainlink/contracts/src/v0.8/interfaces/AggregatorV3Interface.sol"; from NPM
import {ConversionRate} from "./ConversionRate.sol";
import {AggregatorV3Interface} from "@chainlink/contracts/src/v0.8/interfaces/AggregatorV3Interface.sol";

error FundMe__Notowner();

contract FundMe {
    // Type Declaration;
    using ConversionRate for uint256;
    // State Valiable;
    uint256 public constant MINIMUM_USD = 5e18; //5 dollars
    address private immutable i_owner;
    AggregatorV3Interface private s_priceFeed_address;

    address[] private s_funders;
    mapping(address => uint256) private s_addressToAmountFunded;

    modifier OnlyOwner() {
        // require(msg.sender == OWNER, "sender must be owner!");
        if (msg.sender == i_owner) revert FundMe__Notowner();
        _;
    }

    //functions order: 构造、receive、fallback、external、public、internal、private、view/pure

    constructor(address priceFeed_address) {
        i_owner = msg.sender;
        s_priceFeed_address = AggregatorV3Interface(priceFeed_address);
    }

    function Fund() public payable {
        //Allow users to send $
        //Have a minimum $ sent is 5
        //1: How do we send ETh to this contract

        // Want to be able to set a minimum fund amout in USD
        require(
            msg.value.getConversionRate(s_priceFeed_address) >= MINIMUM_USD,
            "doesn't sent enough $"
        );

        s_addressToAmountFunded[msg.sender] += msg.value; //保证同一个人捐几次，钱累计
        s_funders.push(msg.sender);
    }

    function Withdraw() public {
        //for (start_index, end_index, step){}
        for (
            uint256 funderIndex = 0;
            funderIndex < s_funders.length;
            funderIndex++
        ) {
            address funder = s_funders[funderIndex];
            s_addressToAmountFunded[funder] = 0;
        }
        //reset array
        s_funders = new address[](0);
        //withdraw the funds
        // payable(msg.sender).transfer(address(this).balance); //funder send money to this contract

        // bool sendSuccess = payable(msg.sender).send(address(this).balance);
        // require(sendSuccess, "Send Failed");

        (bool callSuccess, ) = payable(msg.sender).call{
            value: address(this).balance
        }("");
        require(callSuccess, "Call-send Failed");
    }

    function WithdrawCheaper() public {
        //for (start_index, end_index, step){}
        uint256 funderLength = s_funders.length;
        for (
            uint256 funderIndex = 0;
            funderIndex < funderLength;
            funderIndex++
        ) {
            address funder = s_funders[funderIndex];
            s_addressToAmountFunded[funder] = 0;
        }
        //reset array
        s_funders = new address[](0);
        //withdraw the funds
        // payable(msg.sender).transfer(address(this).balance); //funder send money to this contract

        // bool sendSuccess = payable(msg.sender).send(address(this).balance);
        // require(sendSuccess, "Send Failed");

        (bool callSuccess, ) = payable(msg.sender).call{
            value: address(this).balance
        }("");
        require(callSuccess, "Call-send Failed");
    }

    receive() external payable {
        Fund();
    }

    fallback() external payable {
        Fund();
    }

    /**
     * View/Pure function (Getters)
     */

    function getAddressToAmountFunded(
        address fundingAddress
    ) external view returns (uint256) {
        return s_addressToAmountFunded[fundingAddress];
    }

    function getFunders(uint256 index) external view returns (address) {
        return s_funders[index];
    }

    function getVersion() external view returns (uint256) {
        return s_priceFeed_address.version();
    }

    function getOwner() external view returns (address) {
        return i_owner;
    }

    function getPriceFeeds() external view returns (AggregatorV3Interface) {
        return s_priceFeed_address;
    }
}

// Concepts we didn't cover yet (will cover in later sections)
// 1. Enum
// 2. Events
// 3. Try / Catch
// 4. Function Selector
// 5. abi.encode / decode
// 6. Hash with keccak256
// 7. Yul / Assembly
