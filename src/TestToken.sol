// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.20;

import  {ERC20} from "../lib/openzeppelin-contracts/contracts/token/ERC20/ERC20.sol";

contract TestToken is ERC20("Test Token","TST"){
    function mint(address receiver, uint amount) external{
        _mint(receiver, amount);
    }
}