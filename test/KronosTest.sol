// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.20;

import "forge-std/Test.sol";
import {Kronos} from "../src/Kronos.sol";
import {TestToken} from "../src/TestToken.sol";

contract KronosTest is Test {
    Kronos public kronos;
    TestToken public token;

    address manager1 = address(0x0001);
    address manager2 = address(0x0002);
    address manager3 = address(0x0003);

    address worker1 = address(0x1000);

    address customer1 = address(0xffff);
    // set up the timeClock, deployer is the manager
    // also set up the test token and give customers tokens
    function setUp() public {
        token = new TestToken();
        vm.prank(manager1);
        kronos = new Kronos(token);
        token.mint(customer1, 1 ether);

    }

    function testPOS() public {
        // first simulate a workers workday
        testWorkday();
        // assert they are not entitled any tokens yet
        assertEq(kronos.maxWithdraw(worker1), 0);

        // now test a customer paying 1 ether
        vm.prank(customer1);
        token.approve(address(kronos), 1 ether);

        vm.prank(customer1);
        token.approve(address(kronos), 1 ether);

        vm.prank(customer1);
        kronos.pay(1 ether);

        // When a user pays assert the tokens are now in kronos
        uint balKronos = token.balanceOf(address(kronos));
        assertEq(balKronos, 1 ether);

        assertEq(balKronos, token.totalSupply());
        
        assertEq(kronos.balanceOf(worker1), kronos.totalSupply());

        // after a workday assert the worker is now entitled to those tokens
        assertEq(kronos.maxWithdraw(worker1), 1 ether);

    }

    mapping (address => uint) internal expected;
    // test profits are actually shared proportionally for a large number of workers working various hours
    function testShares(address[40] memory workers, uint[40] memory hoursWorked) public{
        uint total;

        // first loop
        for (uint i; i < workers.length; i++){

            // Assume a worker cannot work more than 24 hours
            hoursWorked[i] %= 24 hours;

            // if address is 0 expect revert
            if(workers[i] == address(0)){
                continue;
            }

            // if horus == 0 expect revert
            if(hoursWorked[i] == 0){
                vm.prank(workers[i]);
                kronos.clockIn();

                skip(hoursWorked[i]);

                bytes4 selector = bytes4(keccak256("HoursError()"));
                vm.expectRevert(abi.encodeWithSelector(selector));
                vm.prank(workers[i]);
                kronos.clockOut();

                continue;
            }

            // clock in and out
            vm.prank(workers[i]);
            kronos.clockIn();

            skip(hoursWorked[i]);

            vm.prank(workers[i]);
            kronos.clockOut();

            // note the increase in total hours worked
            total += hoursWorked[i];
        }
        
        // have a customer pay some large payment of 100 ether
        vm.prank(customer1);
        token.approve(address(kronos), 100 ether);

        token.mint(customer1, 100 ether);

        vm.prank(customer1);
        kronos.pay(100 ether);

        // assure each worker is owed their share of the 100 ether
        for (uint i; i < workers.length; i++){
            if(workers[i] == address(0) || hoursWorked[i] == 0){
                continue;
            }
            expected[workers[i]] += (1 ether * (100 ether * (hoursWorked[i])) / total) / 1 ether;
        }   
        for (uint i; i < workers.length; i++){
            if(kronos.maxWithdraw(workers[i]) == expected[workers[i]] || kronos.maxWithdraw(workers[i]) == expected[workers[i]] +1){
                assertTrue(true);
            }
        }
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

        assertEq(kronos.balanceOf(worker1), 8 hours * 1 ether);

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
