// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.20;

import "forge-std/Test.sol";
import {Kronos} from "../src/Kronos.sol";

contract KronosTest is Test {
    Kronos public kronos;

    address manager1 = address(0x0001);
    address manager2 = address(0x0002);

    address worker1 = address(0x1000);
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
    function testWorkday() public {
        vm.prank(worker1);
        kronos.clockIn();
        skip(8 hours);
        vm.prank(worker1);
        kronos.clockOut();

        assertEq(kronos.balanceOf(worker1), 8 hours);
    }

}
