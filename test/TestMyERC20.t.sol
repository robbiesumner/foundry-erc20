// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

import {Test} from "forge-std/Test.sol";
import {MyERC20} from "../src/MyERC20.sol";
import {DeployMyERC20} from "../script/DeployMyERC20.s.sol";

contract TestMyERC20 is Test {
    MyERC20 myERC20;

    address ALICE = makeAddr("alice");
    address BOB = makeAddr("bob");
    address CAROL = makeAddr("carol");

    uint256 constant USER_STARTING_BALANCE = 100 ether;

    function setUp() external {
        DeployMyERC20 deployer = new DeployMyERC20();
        myERC20 = deployer.run();

        vm.prank(msg.sender);
        myERC20.transfer(ALICE, USER_STARTING_BALANCE);
    }

    function testAliceStartingBalance() external {
        assertEq(myERC20.balanceOf(ALICE), USER_STARTING_BALANCE);
    }

    /************************* */
    /*** ChatGPT Written Tests */
    /************************* */

    function testAllowances() external {
        assertEq(myERC20.allowance(ALICE, BOB), 0);
        assertEq(myERC20.allowance(BOB, ALICE), 0);

        uint256 TRANFER_AMOUNT = 1 ether;

        uint256 aliceBalance = myERC20.balanceOf(ALICE);
        uint256 bobBalance = myERC20.balanceOf(BOB);

        vm.prank(ALICE);
        myERC20.approve(BOB, TRANFER_AMOUNT);
        assertEq(myERC20.allowance(ALICE, BOB), TRANFER_AMOUNT);
        vm.prank(BOB);
        myERC20.transferFrom(ALICE, BOB, TRANFER_AMOUNT);

        assertEq(myERC20.allowance(ALICE, BOB), 0);
        assertEq(myERC20.balanceOf(ALICE), aliceBalance - TRANFER_AMOUNT);
        assertEq(myERC20.balanceOf(BOB), bobBalance + TRANFER_AMOUNT);
    }

    function testTransfer() external {
        uint256 TRANFER_AMOUNT = 10 ether;

        uint256 aliceBalance = myERC20.balanceOf(ALICE);
        uint256 bobBalance = myERC20.balanceOf(BOB);

        vm.prank(ALICE);
        myERC20.transfer(BOB, TRANFER_AMOUNT);

        assertEq(myERC20.balanceOf(ALICE), aliceBalance - TRANFER_AMOUNT);
        assertEq(myERC20.balanceOf(BOB), bobBalance + TRANFER_AMOUNT);
    }

    function testTransferInsufficientBalance() external {
        uint256 TRANFER_AMOUNT = 101 ether; // More than ALICE's balance

        vm.expectRevert("ERC20: transfer amount exceeds balance");
        myERC20.transfer(BOB, TRANFER_AMOUNT);
    }

    function testTransferFromInsufficientAllowance() external {
        uint256 ALLOWANCE_AMOUNT = 5 ether;

        vm.prank(ALICE);
        myERC20.approve(BOB, ALLOWANCE_AMOUNT);

        vm.expectRevert("ERC20: insufficient allowance");
        myERC20.transferFrom(ALICE, CAROL, ALLOWANCE_AMOUNT);
    }

    function testTransferFrom() external {
        uint256 ALLOWANCE_AMOUNT = 50 ether;
        uint256 TRANFER_AMOUNT = 25 ether;

        vm.prank(ALICE);
        myERC20.approve(BOB, ALLOWANCE_AMOUNT);
        uint256 aliceBalance = myERC20.balanceOf(ALICE);
        uint256 carolBalance = myERC20.balanceOf(CAROL);

        vm.prank(BOB);
        myERC20.transferFrom(ALICE, CAROL, TRANFER_AMOUNT);

        assertEq(
            myERC20.allowance(ALICE, BOB),
            ALLOWANCE_AMOUNT - TRANFER_AMOUNT
        );
        assertEq(myERC20.balanceOf(ALICE), aliceBalance - TRANFER_AMOUNT);
        assertEq(myERC20.balanceOf(CAROL), carolBalance + TRANFER_AMOUNT);
    }
}
