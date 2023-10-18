// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import "forge-std/Test.sol";

contract KronosTest is Test {
    Kronos public kronos;

    address manager1 = 0x0001;
    address manager2 = 0x0002;

    address worker1 = 0x1000;
    // set up the timeClock, deployer is the manager
    function setUp() public {
        vm.prank(manager1);
        kronos = new Kronos();
    }

    // set up a new manager and make sure they have manager permissions
    function testNewManager() public {
        vm.prank(manager1);
        kronos.setNewManager(manager2);
        assertEq(kronos.isManager(manager2), true);
    }

    // a workday happy path of a worker clocking in and out again after 8 hours earning that many tokens
    function workday() public {
        vm.prank(worker1);
        kronos.clockIn();
        vm.warp(8 hours);
        kronos.clockOut();

        assertEq(kronos.balanceOf(worker1), 8 hours);
    }

}
