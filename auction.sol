// SPDX-License-Identifier: MLT
pragma solidity ^0.8;
contract Auction{
    address payable public auctioneer;

    // auction will lasts for a particular time interval
    // having start time and end time in terms of block number
    uint public stblock;
    uint public etblock;

   //  enum formation.. defining auction state 
    enum auction_state {statrted,running,end,cancelled}


    // conaining started, running.. in terms of no output 1
    auction_state public auctionstate= auction_state.running;

    uint public highestbid;
    uint public highestpayablebid;
    uint public  bidincrement;

    // highest bidder
    address  payable public highestbidder;

    // har insaan kitna bid kraha hai usske liyai use hui ha mapping
    mapping(address=>uint) public bids;

    // intializing the value using constructor
    constructor (){
        auctioneer= payable(msg.sender);
        stblock=block.number;
        etblock=stblock+240;// in ethereum one block is made in every 15 sec and in this auction is valid for 1 hr thats why +240
        bidincrement=1 ether;
    

       
    }

    //Function Modifiers are used to modify the behaviour of a function. For example to add a prerequisite to a function
   // auctioner cannot be bidder
   modifier notOwner(){
require(msg.sender!=auctioneer);
_;
    }

     modifier Owner(){
require(msg.sender==auctioneer);
_;
    }

    modifier started(){
        require(block.number>stblock);
        _;
    }
    modifier beforeending (){
        require(block.number<etblock);
        _;
    }

    // auctioneer can cancel the auction using this function
    //modifier owner is used which tells that this function can only be used by owner
 function cancelAuction() public Owner{
   auctionstate= auction_state.cancelled;

 }
 function min(uint a,uint b) pure private returns (uint){
     if(a<=b)
     return a;
     else 
     return b;

 }

    //bidding function use payable which ensures that function can receive and send ether
    function bid() payable public notOwner started beforeending{
        require( auctionstate==auction_state.running);
        require(msg.value>=1 ether);
        uint currentbid=bids[msg.sender]+msg.value;// mapping sai bids lekr msg.sender lga kr bande ki current bid
        require(currentbid>highestpayablebid);
        bids[msg.sender]=currentbid;
if(currentbid<bids[highestbidder]){
 highestpayablebid=min(currentbid+bidincrement,bids[highestbidder]);
}
else{
    highestpayablebid=min(currentbid,bids[highestbidder]+bidincrement);
    highestbidder=payable(msg.sender);
}
}
               function finialize()  public{
                   require(auctionstate==auction_state.cancelled || block.number>etblock);
                   require(msg.sender==auctioneer||bids[msg.sender]>0);
                   address payable person;
                   uint value;
                if(auctionstate==auction_state.cancelled){
                    person=payable(msg.sender);
                    value=bids[msg.sender];
                }
                else{
                    if(msg.sender==auctioneer){
                        person=auctioneer;
                        value=highestpayablebid;
                    }
                    else{
                        if(msg.sender==highestbidder){
                            person=highestbidder;
                            value=bids[highestbidder]-highestpayablebid;
                        }
                        else{
                            person=payable(msg.sender);
                            value=bids[msg.sender];
                        }
                    }
                }
            person.transfer(value);
               }
    }
