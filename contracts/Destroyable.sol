pragma solidity ^0.4.18;



contract Destroyable {
 
  bool destroyed = false;
 

  modifier isNotDestroyed() {
    require(!destroyed);
     _;
  }

}
