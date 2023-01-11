// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;
//import the interface 
import "./interfaceCrowdfunding.sol"; 

//Create an event named launch which comprises of id, creator, goal, startAt, endAt
contract Tech4dev{
    
    event Launch(
        uint id, 
        address indexed creator, 
        uint goal, 
        uint32 startAt, 
        uint32 endAt 
        );

    event Cancel(
        uint id
        );

    event Pledge(
        uint indexed id, 
        address indexed caller, 
        uint amount
    ); 
// Create an event for Unpledge which has id, caller, amount
    event Unpledge(
        uint indexed id, 
        address indexed caller, 
        uint amount
    ); 
// Create an event for Claim which has an id
    event Claim(
        uint id
    );
// Create an event for Refund which has an id that is not indexed, caller and amount
    event Refund(
        uint id, 
        address indexed caller, 
        uint amount
    ); 

//Create a struct named Campaign that has the following: creator, goal, pledged, startAt, endAt, and claimed which is a bool
    struct Campaign{
        address creator;
        uint goal; 
        uint pledged; 
        uint32 startAt; 
        uint32 endAt; 
        bool claimed;

    }

    IERC20 public immutable token; //making reference to the ERC20 token

    uint public count; 

    mapping(uint => Campaign) public campaigns; //mapping from id to Campaign 

    mapping(uint => mapping(address => uint)) public pledgedAmount; 

    constructor(address _token){
        token = IERC20(_token); 
    }

    function launch(uint _goal, uint32 _startAt, uint32 _endAt) external{
        require(_startAt >= block.timestamp, "startAt < now");
        require(_endAt >= _startAt, "end at < start at"); 
        require(_endAt <= block.timestamp + 90 days, "end at > max duration"); 


// Create a struct input that contains the following: 
//msg.sender, _goal, 0, _startAt, _endAt, false

    count += 1; 
    campaigns[count] = Campaign(msg.sender, _goal, 0, _startAt, _endAt, false); 

    emit Launch(count, msg.sender, _goal, _startAt, _endAt); 

    }

    function cancel(uint _id) external{
    Campaign memory campaign = campaigns[_id]; 

    require(campaign.creator == msg.sender, "You are not the creator of this campaign"); 
    require(block.timestamp < campaign.startAt, "The campaign has started"); 

    delete campaigns [_id]; 
    emit Cancel(_id); 
    }

    function pledge(uint _id, uint _amount) external { 
    Campaign storage campaign = campaigns[_id]; 
    require(block.timestamp >= campaign.startAt, "Campaign has not started"); 
    require(block.timestamp <= campaign.endAt, "Campaign has ended"); 
    campaign.pledged += _amount; 
    pledgedAmount[_id][msg.sender] += _amount; 
    token.transferFrom(msg.sender, address(this), _amount); 
    
    emit Pledge(_id, msg.sender, _amount); 

    }

    function unpledge(uint _id, uint _amount) external{
    Campaign storage campaign = campaigns[_id];

    require(block.timestamp <= campaign.endAt, "Campaign has ended"); 
    campaign.pledged -= _amount; 
    pledgedAmount[_id][msg.sender] -= _amount; 
    token.transfer(msg.sender, _amount); 

    emit Unpledge(_id, msg.sender, _amount); 
    }

    function claim(uint _id) external{ //id of the campaign we want to claim for 
        Campaign storage campaign = campaigns[_id]; //gives us access to struct and using storage in order to be able to update

        //the person that is claiming must be the campaign creator (creator that is coming from the struct so we just concatenate it)
        require(campaign.creator == msg.sender, "You are not the owner"); 
        require(block.timestamp > campaign.endAt, "Campaign has not ended yet"); //now is greater than endAt, if you want to withdraw, make sure that the campaign has ended 
        require(campaign.pledged >= campaign.goal, "pledged < goal, the goal was not reached"); //check if the campaign has succeeded by checking the total supply raised of the campaign has exceeded the objective that was set 
        require(!campaign.claimed, "Campaign has been claimed"); //require that the campaign was not claimed before 
        
        
        campaign.claimed = true; //transfer to the person that has created the campaign 
        token.transfer(campaign.creator, campaign.pledged); 
        emit Claim(_id); 
    }
    
    function refund(uint _id) external{
        Campaign memory campaign = campaigns[_id]; 
        require(block.timestamp > campaign.endAt, "Campaign has not ended");//if the campaign has not ended, you cannot request the refund
        require(campaign.pledged < campaign.goal, "pledged >= goal"); 

        uint balance = pledgedAmount[_id][msg.sender]; //to track how much do you have 
        pledgedAmount[_id][msg.sender] = 0; //the money is tied to a particular address, equating it to 0 to nullify everything that you have, the amount that you are trying to pledge
        token.transfer(msg.sender, balance); //then transfer the amount to the person calling the function and the balance

        emit Refund(_id, msg.sender, balance); 
        
        
        }

}


