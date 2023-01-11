// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

/* creating an interface since we are using an ERC-20 token, 
in order to enable the main contract to call 
the transfer and transferFrom functions from the ERC-20 token contract*/ 

interface IERC20{
    function transfer(address recipient, uint amount) external returns(bool);
    function transferFrom(address sender, address recipient, uint amount) external returns(bool); 

    
}

