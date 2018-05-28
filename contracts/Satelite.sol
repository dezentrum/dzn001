pragma solidity ^0.4.18;

import "./Fundable.sol";
import "./ownership/Ownable.sol";



contract Satelite is Ownable  {

    Fundable fundingContract;
    uint256 nounce;

    constructor() public {
        owner = msg.sender;
    }


    function claim(address _fundingContract) returns (bool) {
        fundingContract = Fundable(_fundingContract);
        fundingContract.getNounce();
        return true;
    }

}
