//SPDX-License-Identifier: GPL-3.0

pragma solidity ^0.8.24;

import {Test, console} from "forge-std/Test.sol";
import {fundMe} from "../../src/fundMe.sol";
import {DeployFundMe} from "../../script/DeployFundMe.s.sol";
import {HelperConfig} from "../../script/HelperConfig.s.sol";

contract FundMeTest is Test {
    fundMe fundme;
    HelperConfig config;
    DeployFundMe deployer;

    address user = makeAddr("user");

    function setUp() external {
        vm.deal(user, 100 ether);
        deployer = new DeployFundMe();
        (fundme, config) = deployer.run();
    }

    function testOwner() external view {
        assertEq(fundme.getOwner(), msg.sender);
    }

    function testDeposit() external {
        vm.startPrank(user);
        vm.expectRevert(fundMe.increaseThreshold.selector);
        fundme.depositFund{value: 0.001 ether}();
        vm.stopPrank();
    }

    function testMinDeposit() external {
        uint256 amountInUsd = fundme.conversion(100e18);
        uint256 ethPrice = fundme.getEthUsd();
        console.log(amountInUsd);
        console.log(ethPrice);
    }

    function testDepositCount() external {
        uint256 sendCount = fundme.getDepositCount(user);
        // vm.expectRevert(fundMe.onceDepositAllowed.selector);
        vm.startPrank(user);
        fundme.depositFund{value: 0.1 ether}();
        vm.stopPrank();
        assertEq(sendCount, 0);
    }

    modifier deposit() {
        vm.startPrank(user);
        fundme.depositFund{value: 0.1 ether}();
        _;
    }

    function testDoubleDeposit() external deposit {
        uint256 sendCount = fundme.getDepositCount(user);
        vm.expectRevert(fundMe.onceDepositAllowed.selector);
        vm.startPrank(user);
        fundme.depositFund{value: 0.5 ether}();
        vm.stopPrank();
        console.log(sendCount);
    }

    function testWithdraw() external {
        // using uint160 to generate addresses due to hoax cheat code
        uint160 funderIndex = 10;
        for (uint160 i = 0; i < funderIndex; i++) {
            hoax(address(i), 1 ether);
            fundme.depositFund{value: 0.1 ether}();
        }
        uint256 bal = fundme.getBalance();
        console.log(bal);
        vm.startPrank(fundme.getOwner());
        fundme.withdraw();
        bal = fundme.getBalance();
        console.log(bal);
        vm.stopPrank();
        assertEq(address(fundme).balance, 0);
    }
}
