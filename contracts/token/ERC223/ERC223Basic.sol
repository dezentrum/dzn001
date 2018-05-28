pragma solidity ^0.4.18;

 /* 
  * @Dev Based On: https://github.com/Dexaran/ERC223-token-standard/blob/master/token/ERC223/
 */
contract ERC223Basic {
    function totalSupply() public view returns (uint256);
    function balanceOf(address who) public view returns (uint256);
    function transfer(address to, uint256 value) public returns (bool);
    function transfer(address to, uint256 value, bytes data)public returns (bool);
    event Transfer(address indexed from, address indexed to, uint256 value, bytes data);
}