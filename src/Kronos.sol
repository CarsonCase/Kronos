// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.20;

import  {ERC20} from "../lib/openzeppelin-contracts/contracts/token/ERC20/ERC20.sol";

// Happy path passes! 
// But inw writting this code I noticed some not so happy things...
contract Kronos is ERC20("TimeLock Tokens", "TLT"){
    mapping(address => bool) private _isManager;
    mapping(address => Status) private _clockStatus;

    struct Status{
        bool clockedIn;
        uint lastClock;
    }

    error AccessError(address caller);
    error RepeatClock();

    constructor(){
        _isManager[msg.sender] = true;
    }

    function setNewManager(address _newManger) external {
        if(_isManager[msg.sender]){
            _isManager[_newManger] = true;
        }else{
            revert AccessError(msg.sender);
        }
    }

    function isManager(address _account) external view returns(bool){
        return _isManager[_account];
    }

    function clockIn() external{
        if(!_clockStatus[msg.sender].clockedIn){
            _clockStatus[msg.sender] = Status(true, block.timestamp);
        }else{
            revert RepeatClock();
        }
    }

    function clockOut() external{
        if(_clockStatus[msg.sender].clockedIn){
            _clockStatus[msg.sender].clockedIn = false;
            uint clockInTime = _clockStatus[msg.sender].lastClock;
            uint clockOutTime = block.timestamp;
            _clockStatus[msg.sender].lastClock = clockOutTime;
            _mint(msg.sender, clockOutTime - clockInTime);
        }else{
            revert RepeatClock();
        }
    }
}
