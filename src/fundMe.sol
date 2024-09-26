//SPDX-License-Identifier: GPL-3.0

pragma solidity ^0.8.26;

import {AggregatorV3Interface} from "@chainlink/contracts/src/v0.8/interfaces/AggregatorV3Interface.sol";

contract fundMe {
    address s_owner;
    uint256 constant MIM_DEPOSIT = 100e18; // Value is usd
    address[] depositors; // Array of depositors to track funders
    AggregatorV3Interface priceFeed;

    struct userInfo {
        uint256 depositCount;
        uint256 amount;
    }
    //MAPPINGS

    mapping(address depositor => userInfo) deposits;

    //ERRORS
    error increaseThreshold();
    error onlyOwnerFunction();
    error onceDepositAllowed();

    constructor(address _priceFeed) {
        s_owner = msg.sender;
        priceFeed = AggregatorV3Interface(_priceFeed);
    }

    modifier onlyOwner() {
        if (msg.sender != s_owner) revert onlyOwnerFunction();
        _;
    }

    function depositFund() public payable {
        if (conversion(msg.value) < MIM_DEPOSIT) {
            revert increaseThreshold();
        }
        if (deposits[msg.sender].depositCount > 0) revert onceDepositAllowed();
        deposits[msg.sender].amount += msg.value;
        deposits[msg.sender].depositCount += 1;
        depositors.push(msg.sender);
    }

    function getEthUsd() public returns (uint256) {
        priceFeed = AggregatorV3Interface(priceFeed); //)
        (, int256 price,,,) = priceFeed.latestRoundData();
        return uint256(price * 1e10);
    }

    function conversion(uint256 amount) public returns (uint256) {
        uint256 ethPrice = getEthUsd();
        uint256 amountInUsd = (ethPrice * amount) / 1e18;
        return amountInUsd;
    }

    function withdraw() public onlyOwner {
        //start withdrawal from index 1
        for (uint256 depositorIndex = 0; depositorIndex < depositors.length; depositorIndex++) {
            address depositor = depositors[depositorIndex];
            deposits[depositor].amount = 0;
        }
        // reset the depositors array to zero
        depositors = new address[](0);
        (bool success,) = payable(msg.sender).call{value: address(this).balance}("");
        require(success, "transaction failed");
    }

    //Getter Functions
    function getOwner() public view returns (address) {
        return s_owner;
    }

    function getDepositCount(address user) public view returns (uint256 count) {
        return count = deposits[user].depositCount;
    }

    function getBalance() public view returns (uint256 bal) {
        return bal = address(this).balance;
    }
}
