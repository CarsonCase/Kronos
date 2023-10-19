// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import  {ERC20} from "openzeppelin/contracts/token/ERC20/ERC20.sol";

contract Kronos is ERC20("TimeLock Tokens", "TLT"){
    function setNewManager(address _newManger) external {

    }

    function isManager(address _account) external view returns(bool){

    }

    function clockIn() external{}

    function clockOut() external{}
}
