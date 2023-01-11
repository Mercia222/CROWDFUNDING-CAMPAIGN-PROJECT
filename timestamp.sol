// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0; 

/*block.timestamp is Now by default and now is in seconds 
So block.timestamp = 1 second
(But it returns in milliseconds after compilation) 

So if we want to program our campaign in days or hours, we need to add days or hours to that block.timestamp */ 

contract time{
    function second() public view returns(uint){
        return block.timestamp + 50 seconds; 
    }

    function secondz() public view returns(uint){
        return block.timestamp + 60 seconds; 
    }

    function minute() public view returns(uint){
        return block.timestamp + 8 minutes; 
    }

    function day() public view returns(uint){
        return block.timestamp + 1 days; 
    }

    function hour() public view returns(uint){
        return block.timestamp + 3 hours; 
    }
}
