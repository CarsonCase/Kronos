// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.20;

import  {ERC20, IERC20} from "../lib/openzeppelin-contracts/contracts/token/ERC20/ERC20.sol";
import  {ERC4626} from "../lib/openzeppelin-contracts/contracts/token/ERC20/extensions/ERC4626.sol";

// New inheritance
contract Kronos is ERC4626{
    IERC20 public underlying;

    mapping(address => bool) private _isManager;
    mapping(address => Status) private _clockStatus;

    struct Status{
        bool clockedIn;
        uint lastClock;
    }

    error AccessError(address caller);
    error RepeatClock();

    // New constructor
    constructor(IERC20 _underlying) ERC4626(_underlying) ERC20("TimeLock Tokens", "TLT"){
        _isManager[msg.sender] = true;
        underlying = _underlying;
    }

    // New function
    function pay(uint _amount) external{

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
        Status memory statusMemory = _clockStatus[msg.sender];
        Status storage statusStorage = _clockStatus[msg.sender];
        if(statusMemory.clockedIn){
            statusStorage.clockedIn = false;
            uint clockInTime = statusMemory.lastClock;
            uint clockOutTime = block.timestamp;
            statusStorage.lastClock = clockOutTime;
            _mint(msg.sender, clockOutTime - clockInTime);
        }else{
            revert RepeatClock();
        }
    }
}
