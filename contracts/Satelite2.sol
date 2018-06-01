pragma solidity ^0.4.18;

import "./ownership/Ownable.sol";
import "zeppelin-solidity/contracts/math/SafeMath.sol";

contract Satelite2 is Ownable {
    using SafeMath for uint256;
    event payed(uint256 i, address indexed to, uint256 amount);

    uint256 public constant dezentrumPart = 15;
    uint256 public constant satelitePart = 3;

    address dezentrumW; //=decentrum wallet

    Proposal[] proposals;

    uint256 claimTime;
    uint256 claimNonce;
    address claimer;
    Proposal claimedProposal;

    struct Proposal {
        int256 lat;
        int256 lon;
        uint256 balance;
        bool finished;
    }

    function Satelite2() public {
        owner = msg.sender; // Potentially hardcode this to dezentrum multisig
    }

    modifier isNotClaimed() {
        require(claimTime < block.timestamp-60*60*30); // require there is not running claim
        _;
    }

    modifier isClaimed() {
        require(claimTime >= block.timestamp-60*60*30); // require it has not expired yet
        require(claimer != 0x0); // require that there *is* actual claimer
        _;
    }

    function unclaim() onlyOwner {
        claimTime = 0;
    }

    function getClaimNonce() view public returns (uint256) {
        return claimNonce;
    }

    function getNumberofProposals() view public returns (uint256) {
        return proposals.length;
    }

    function getProposal(i) view public returns (uint256, uint256, uint256, bool) {
        return (proposals[i].lat, proposals[i].lon, proposals[i].balance, proposals[i].finished);
    }

    function claim(uint256 _i, uint256 _nonce) isNotClaimed public returns (bool) {
        require(msg.sender != 0x0);
        claimer = msg.sender;
        claimTime = block.timestamp;
        claimNonce = _nonce;
        claimedProposal = proposals[_i];
        return true;
    }

    // function confirmClaim(uint256 actualNonce) onlySatellite returns (bool) {}

    function payout() onlyOwner isClaimed public returns (bool) { // Why onlyOwner? ~onlyClaimer?
        uint256 total = claimedProposal.balance;
        uint256 sateliteAmount = total.multiply(satelitePart).divide(100);
        uint256 dezentrumAmount = total.multiply(dezentrumPart).divide(100);
        uint256 claimer = total.sub(satelite).sub(dezentrum);
        msg.sender.transfer(claimer);
        dezentrumW.transfer(dezentrum);
        owner.transfer(satelite); /* Do we need to do this? Can we leave it on an internal balance? Or send it to the satellite contract? */
        claimedProposal.finished = true;
        claimedProposal.balance = 0;
        return true;
    }

    function addProposal (int256 _lat, int256 _lon) public returns (uint256)
    {
        // Check _lat _lon for actual coordinates (-180 to 180, -90 to 90 => int256?)
        var newProposal = new Proposal();
        newProposal.lat = _lat;
        newProposal.lon = _lon;
        return proposals.push(newProposal)-1;
    }

    function fundProposal(i) payable  {
        proposals[i].balance = proposals[i].balance.add(msg.value);
        emit payed(i,msg.sender,msg.value);
    }

}
