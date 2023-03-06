// SPDX-License-Identifier: MIT

pragma solidity >=0.5.0 < 0.9.0;

contract CrowdFunding{

    address public manager;
    mapping(address => uint) public contributors; // storing ethers against adderss of user
    uint public minContribution;
    uint public deadline;
    uint public target;
    uint public raisedAmount;
    uint public noOfContributors;
	
	struct Request{
        string description;
        address payable recipient;
        uint value;
        bool completed;
        uint noOfVoters;
        mapping(address => bool) voters;
    }
    mapping(uint => Request) public requests; //mapping the request with index
    uint public numRequests;

    constructor(uint _target, uint _deadline) {
        target = _target;
        deadline = block.timestamp + _deadline; //10sec+ add in seconds;
        minContribution = 100 wei;
        manager = msg.sender;
    }

    function sendEth() public payable{
        require(block.timestamp < deadline, "Deadline has passed.");
        require(msg.value>= minContribution, "Please met minimum contribution.");

        if(contributors[msg.sender]==0){
            noOfContributors++;
        }
        contributors[msg.sender] += msg.value;
        raisedAmount += msg.value;
    }
    function getContractBalance() public view returns (uint){
        return address(this).balance;
    }

    function refunnd() public {
        require(block.timestamp >= deadline && raisedAmount <target, "You are not eligible for refund");
        require(contributors[msg.sender]>0); // checking if user have donates or not
        address payable user = payable(msg.sender); 
        user.transfer(contributors[msg.sender]);// transfering all it's ether which is saved against it's address using mapping
        contributors[msg.sender] = 0;
        }

     modifier onlyManager {
        require(msg.sender == manager, "Only manager can make Fund request.");
        _;
    }
     function createRequest(string memory _description, address payable _recipient, uint _value) public onlyManager{
        Request storage newRequest = requests[numRequests];
        numRequests++;
        newRequest.description = _description;
        newRequest.recipient = _recipient;
        newRequest.value = _value;
        newRequest.completed = false;
        newRequest.noOfVoters = 0;
    }
    function voteRequest(uint _requestNo) public{
        require(contributors[msg.sender]>0, "You must be a contributor.");
        Request storage thisRequest = requests[_requestNo];
        require(thisRequest.voters[msg.sender] == false, "you have already voted.");
        thisRequest.voters[msg.sender] = false;
        thisRequest.noOfVoters++;
    }
    function makePayment(uint _requestNo) public onlyManager {
        require(raisedAmount>=target);
        Request storage thisRequest = requests[_requestNo];
        require(thisRequest.completed == false,"the request has been completed.");
        require(thisRequest.noOfVoters > noOfContributors/2, "Majority doesn't support");
        thisRequest.recipient.transfer(thisRequest.value);
    }
}


    
   //0xd9145CCE52D386f254917e481eB44e9943F39138
