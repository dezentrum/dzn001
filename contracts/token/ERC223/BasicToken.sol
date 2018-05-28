pragma solidity ^0.4.18;


import "./ERC223Basic.sol";
import "./ERC223ReceivingContract.sol";
import "zeppelin-solidity/contracts/math/SafeMath.sol";

/**
 * @title Basic token
 * @dev Basic version of StandardToken, with no allowances.
 * Based on Open Zeppelin ERC20Basic Token
 * Transfer functions used of 
 */
contract BasicToken is ERC223Basic {
  using SafeMath for uint256;
  

  mapping(address => uint256) balances;

  uint256 totalSupply_;

  /**
  * @dev total number of tokens in existence
  */
  function totalSupply() public view returns (uint256) {
    return totalSupply_;
  }

  /**
  * @dev basedOn https://github.com/Dexaran/ERC223-token-standard/blob/master/token/ERC223/
  * @dev Transfer the specified amount of tokens to the specified address.
  *      Invokes the `tokenFallback` function if the recipient is a contract.
  *      The token transfer fails if the recipient is a contract
  *      but does not implement the `tokenFallback` function
  *      or the fallback function to receive funds.
  *
  * @param _to    Receiver address.
  * @param _value Amount of tokens that will be transferred.
  * @param _data  Transaction metadata.
  */
  function transfer(address _to, uint256 _value, bytes _data)  public returns (bool) {
    // Standard function transfer similar to ERC20 transfer with no _data .
    // Added due to backwards compatibility reasons .
    require(_to != address(0)); //Added by Ahauri
    require(_value <= balances[msg.sender]); //Added by Ahauri

    uint codeLength;

    assembly {
      // Retrieve the size of the code on target address, this needs assembly .
      codeLength := extcodesize(_to)
    }

    // SafeMath.sub will throw if there is not enough balance.
    balances[msg.sender] = balances[msg.sender].sub(_value);
    balances[_to] = balances[_to].add(_value);
    if(codeLength>0) {
      ERC223ReceivingContract receiver = ERC223ReceivingContract(_to);
      receiver.tokenFallback(msg.sender, _value, _data);
    }
    emit Transfer(msg.sender, _to, _value, _data);
    return true; //Added by Ahauri
  }
    
  /**
    * @dev basedOn https://github.com/Dexaran/ERC223-token-standard/blob/master/token/ERC223/
    * @dev Transfer the specified amount of tokens to the specified address.
    *      This function works the same with the previous one
    *      but doesn't contain `_data` param.
    *      Added due to backwards compatibility reasons.
    *
    * @param _to    Receiver address.
    * @param _value Amount of tokens that will be transferred.
    */
  function transfer(address _to, uint256 _value) public returns (bool) {
    require(_to != address(0)); //Added by Ahauri
    require(_value <= balances[msg.sender]); //Added by Ahauri
    uint codeLength;
    bytes memory empty;
   
    assembly {
      // Retrieve the size of the code on target address, this needs assembly.
      codeLength := extcodesize(_to)
    }
   

    // SafeMath.sub will throw if there is not enough balance.
    balances[msg.sender] = balances[msg.sender].sub(_value);
    balances[_to] = balances[_to].add(_value);
    if(codeLength>0) {
      ERC223ReceivingContract receiver = ERC223ReceivingContract(_to);
      receiver.tokenFallback(msg.sender, _value, empty);
    }
    emit Transfer(msg.sender, _to, _value, empty);
    return true;
  }

  /**
  * @dev Gets the balance of the specified address.
  * @param _owner The address to query the the balance of.
  * @return An uint256 representing the amount owned by the passed address.
  */
  function balanceOf(address _owner) public view returns (uint256 balance) {
    return balances[_owner];
  }

}
