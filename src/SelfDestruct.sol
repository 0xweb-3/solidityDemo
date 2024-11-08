pragma solidity ^0.8.13;

contract SelfDestruct{
    address payable public destructer;
    address payable public owner;

    modifier OnlyOwner() {
        require(msg.sender == owner, "only owner call");
        _;
    }

    receive() external payable {}

    
    constructor(){
        owner = payable(msg.sender);
    }

    function close() public OnlyOwner(){
        selfdestruct(owner);
    }
}
