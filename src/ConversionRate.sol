//SPDX-License-Identifier: MIT

pragma solidity ^0.8.18;

import {AggregatorV3Interface} from "@chainlink/contracts/src/v0.8/interfaces/AggregatorV3Interface.sol";

library ConversionRate {
    // we need get price
    function getPrice(
        AggregatorV3Interface priceFeed_address
    ) internal view returns (uint256) {
        //Address 0x694AA1769357215DE4FAC081bf1f309aDC325306 ETH/USD
        //ABI
        (, int256 price, , , ) = priceFeed_address.latestRoundData();
        return uint(price * 1e10); //this price is ETH/USD price=200000000000*1e10=2000*1e18
    }

    //transfer USD into ETH
    function getConversionRate(
        uint256 ethAmount,
        AggregatorV3Interface priceFeed_address
    ) internal view returns (uint256) {
        //ethAmount is msg.value
        //1 eth = 2000_1e18 usd

        uint256 ethPrice = getPrice(priceFeed_address);
        uint256 ethAmontInUsd = (ethAmount * ethPrice) / 1e18;
        return ethAmontInUsd;
    }
}
