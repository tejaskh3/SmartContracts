// SPDX-License-Identifier: MIT

pragma solidity >=0.5.0 <0.9.0;

contract Lottery{
    address public manager;
    address payable[] public participants;
    
    constructor()
    {
        manager=msg.sender; // global variable
    }

    receive() external payable{ // can only use once in a contract
        require(msg.value == 0.01 ether);
        participants.push(payable(msg.sender));
    }
    function getBalance() public view returns(uint){
        require(msg.sender== manager);
        return address(this).balance;
    }
    function random() public view returns(uint){
        return uint(keccak256(abi.encodePacked(block.difficulty, block.timestamp,participants.length)));  
    }

    function selectWinner() public {
        require(msg.sender==manager);
        require(participants.length>=3);
        uint r=random();
        address payable winner;
        uint index = r%participants.length;
        winner = participants[index];
        winner.transfer(getBalance());
        participants = new address payable[](0);
    }

}

// 0xD0C14ade05Ec0F31E488512ecAB337A70dDd7B6b
