// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.20;

import  {ERC20} from "../lib/openzeppelin-contracts/contracts/token/ERC20/ERC20.sol";

// Happy path passes! 
// But inw writting this code I noticed some not so happy things...
contract Kronos is ERC20("TimeLock Tokens", "TLT"){
    mapping(address => bool) private _isManager;
    mapping(address => uint) private _lastClocks;

    function setNewManager(address _newManger) external {
        /// todo access control
        _isManager[_newManger] = true;
    }

    function isManager(address _account) external view returns(bool){
        return _isManager[_account];
    }

    function clockIn() external{
        // todo access control
        _lastClocks[msg.sender] = block.timestamp;
    }

    function clockOut() external{
        // todo access control
        uint clockInTime = _lastClocks[msg.sender];
        uint clockOutTime = block.timestamp;
        _lastClocks[msg.sender] = clockOutTime;
        _mint(msg.sender, clockOutTime - clockInTime);
    }
}
