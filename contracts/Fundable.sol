pragma solidity ^0.4.18;



contract Fundable {
  function payout() public  returns (bool);
  function getNounce() public view returns (uint256);
  event payed(address indexed to, uint256 amount);
}
