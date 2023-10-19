// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.20;

import "forge-std/Test.sol";
import {Kronos} from "../src/Kronos.sol";

contract KronosTest is Test {
    Kronos public kronos;

    address manager1 = address(0x0001);
    address manager2 = address(0x0002);
    address manager3 = address(0x0003);

    address worker1 = address(0x1000);
    // set up the timeClock, deployer is the manager
    function setUp() public {
        vm.prank(manager1);
        kronos = new Kronos();
    }

    // a workday happy path of a worker clocking in and out again after 8 hours earning that many tokens
    function testWorkday() public {
        // Clock in
        vm.prank(worker1);
        kronos.clockIn();

        // Fail to clock in a second time
        bytes4 selector = bytes4(keccak256("RepeatClock()"));
        vm.expectRevert(abi.encodeWithSelector(selector));
        vm.prank(worker1);
        kronos.clockIn();

        // skip forward 8 hours
        skip(8 hours);

        // sucessfully clock out with tokens
        vm.prank(worker1);
        kronos.clockOut();

        assertEq(kronos.balanceOf(worker1), 8 hours);

        // Fail to clock out a second time
        vm.expectRevert(abi.encodeWithSelector(selector));
        vm.prank(worker1);
        kronos.clockOut();
    }

    // set up a new manager and make sure they have manager permissions
    function testNewManager() public {
        //epect a non-manager to fail to set a new manager
        bytes4 selector = bytes4(keccak256("AccessError(address)"));
        vm.expectRevert(abi.encodeWithSelector(selector, worker1));
        newManager(worker1, worker1, true);

        // expect a manager to be able to set a new manager
        newManager(manager1, manager2, false);

        // finally the new manager should be able to set another manager
        newManager(manager2, manager3, false);

    }

    // helper function to test the newManager function
    function newManager(address caller, address manager, bool shouldError) internal{
        vm.prank(caller);
        kronos.setNewManager(manager);
        if(!shouldError){
            assertEq(kronos.isManager(manager), true);
        }
    }


}
