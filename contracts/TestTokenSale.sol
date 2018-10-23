pragma solidity ^0.4.20;

import "./TestToken.sol"; 
import "./SafeMath.sol";

/**
 *  The crowdsale contract is the first draft of the tokensale,
    with the timed transitions for the stages and variable prices. 
 */
contract TestTokenSale{

  using SafeMath for uint256;

  enum Stages{
    saleStarted,
    saleStage1,
    saleEnded
  }

  address public admin;
  TestToken public tokenContract; 
  uint256 public tokenPrice;
  uint256 public tokensSold;

  string public name;
  
  uint256 public endTime;
  event Sell(address _buyer, uint256 _amount);

  /* this is for the test purpose of the stages  
   */
   modifier onlyAdmin{
    require (msg.sender == admin);
    _;
   }

  Stages public stage = Stages.saleStarted;
  uint256 public startTime = block.number; 

  // modifier for the next stage of the sale 
  function nextStage() internal{
    stage = Stages(uint256(stage) + 1);
  }

  // time transitions 
  modifier timedTransitions(){
    if(stage == Stages.saleStarted && block.number >= startTime + 7){
      nextStage(); 
    }
    if(stage == Stages.saleStage1 && block.number >= startTime + 15){
      nextStage();
    }
    if(stage == Stages.saleEnded){
      endSale();
    }
    _;

  }

  constructor(TestToken _tokenContract, uint256 _tokenPrice, uint256 _endTime) public{

    admin = msg.sender;
    tokenContract = _tokenContract;
    tokenPrice = _tokenPrice;
    endTime = _endTime;
  }

  //high level purchase 
  function() external timedTransitions payable{
    buyTokensHere(msg.sender); 
  }

    //low level purchase with the function being called inside
  function buyTokensHere(address _beneficiary) public timedTransitions payable{ // change it to buyTokens
    
    require(msg.value != 0);
    uint256 weiAmount = msg.value;
    uint256 _numberOfTokens = _getTokenAmount(weiAmount);
    //require(tokenContract.balanceOf(this) >= _numberOfTokens);
    //require(tokenContract.transfer(msg.sender, _numberOfTokens));
    //tokenContract.transfer(_beneficiary, _numberOfTokens); // this when sale is the owner
    tokenContract.mintToken(_beneficiary, _numberOfTokens);
    tokensSold += _numberOfTokens;
    emit Sell(msg.sender, _numberOfTokens);
  }


  // gives the number of tokens to the amount of ether sent to contract
  // this is where we do the numbers wrt the ether sent to the sale address.
  function _getTokenAmount(uint256 _weiAmount) internal view returns(uint256){    
    if(stage == Stages.saleStarted){
      return _weiAmount.div(tokenPrice);
    }
    if(stage == Stages.saleStage1){
      return _weiAmount.div(tokenPrice - 5e16);//50000000000000000);
    }
  }

  //token sale ends and the function related to that goes here
  function endSale() public onlyAdmin {
    require(stage == Stages.saleEnded);
    admin.transfer(address(this).balance);
  }

  function emergencyExtract() public onlyAdmin{
    admin.transfer(address(this).balance);
  }



}

