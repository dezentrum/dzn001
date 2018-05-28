pragma solidity ^0.4.18;


import "./Claimable.sol";
import "./Fundable.sol";
import "zeppelin-solidity/contracts/math/SafeMath.sol";


contract Funding is Claimable, Fundable {
  using SafeMath for uint256;

  uint256 public constant dezentrumPart = 15; 
  uint256 public constant satelitePart = 3;

  address dezentrumW; //=decentrum wallet
  address sateliteW; //=decentrum wallet
  uint32 lat;
  uint32 lon;
  bytes32 linkH;
  string link;

  
  constructor(uint32 _lat,uint32 _lon,bytes32 _linkH,string _link) public {
    lat =_lat;
    lon = _lon;
    linkH = _linkH;
    link = _link;  
    //owner = fixedToContractOfSatelite;
  }

  function payout() onlyOwner isClaimed isNotDestroyedn public returns (bool) {
    uint256 total = address(this).balance;
    uint256 satelite = total.multiply(satelitePart).divide(100);
    uint256 dezentrum = total.multiply(dezentrumPart).divide(100);
    uint256 claimer = total.sub(satelite).sub(dezentrum);
    msg.sender.transfer(claimer);
    dezentrumW.transfer(decentrum);
    sateliteW.transfer(satelite);
    destroyed = true;
    assert(address(this).balance==0);
    return true;
  }

  function () isNotDestroyed payable  {
    payed(msg.sender,msg.value);
  }

  //getting the current balance of the wallet.
  function getBalance() view public returns (uint) {
      return address(this).balance;
  }

  function getNounce() view public returns (uint) {
      return nounce;
  }

}
