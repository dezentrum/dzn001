pragma solidity ^0.4.18;


import "./ownership/Ownable.sol";
import "./Destroyable.sol";


contract Claimable is Ownable, Destroyable {
 
  bool public claimed = false;
  uint256 claimtime;
  uint256 nounce;
  address claimer;

  modifier isNotClaimed() {
    require(claimtime<block.timestamp-60*60*30);
     _;
  }
 
  modifier isClaimed() {
    require(claimtime>=block.timestamp-60*60*30);
    require(claimer != 0x0);
    _;
  }

  function unclaim() onlyOwner isNotDestroyed {
      claimtime = 0;
  }

  function claim(address _claimer,uint256 _nounce) isNotClaimed  isNotDestroyed returns (bool) {
    claimtime = block.timestamp;
    claimer = _claimer;
    nounce = _nounce;
    return true;
  }

}
