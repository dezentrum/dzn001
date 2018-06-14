pragma solidity ^0.4.24;

import "./ownership/Ownable.sol";
import "zeppelin-solidity/contracts/math/SafeMath.sol";

contract Satelite2 is Ownable {
    using SafeMath for uint256;

    //  Constant share declaration
    uint256 public constant DECENTRUM_PART = 15;
    uint256 public constant SATELITE_PART = 3;
    //  Constant addresses declaration
    address public constant DECENTRUM_WALL = 0x0; //TODO: fill the Dezentrum wallet

    //  Proposal object definition
    struct Proposal {
        uint256 lat;
        uint256 lon;
        uint256 balance;
        bool finished;
    }

    //  Proposal mapping
    uint256 public proposalCounter;
    mapping (uint256 => Proposal) proposals;

    //  Claim related variables //TODO: decide if public
    uint256 attemptedClaimID;
    uint256 attemptTimestamp;
    address attempting;

    uint256 nonce;

    address claimer;
    uint256 claimedProposalID;
    uint256 claimTime;

    //  Event declarations
    event EntityGenesis(string origin);
    event ClaimAttemptSubmitted(uint256 proposalID, uint256 nonce, address claimer);
    event ClaimAttemptConfirmed(uint256 proposalID, uint256 nonce, address claimer);
    event ClaimApproved(uint256 proposalId, uint256 nonce, address claimer);
    event ProposalAdded(uint256 proposalID, uint256 lat, uint256 lon, address indexed proposer);
    event ProposalClaimed(uint256 proposalID, uint256 nonce, uint256 claimTime, address indexed claimer);
    event ProposalFunded(uint256 proposalID, uint256 oldBalance, uint256 newBalance, address indexed donor);
    event RewardPaid(uint256 proposalID, address indexed claimer, uint256 amount);
    event SelfDestructInitiated(string destination);

    //  Modifier declaration
    //  @dev Modifier defining a time period for the satellite not to be considered as actually claimed
    modifier isNotClaimed() {
        require(now - claimTime >= 30 hours);
        _;
    }

    //  @dev Modifier defining a time period for the satellite to be considered as actually claimed
    modifier isClaimed() {
        require(now - claimTime < 30 hours);
        require(claimer != 0x0);
        _;
    }

    /*
     *  @title Satellite
     *  @dev Constructor of the autonomous satellite entity
     *  @param string origin is the location where the autonomous entity first came to live
     */
    constructor(string origin) public {
        owner = msg.sender;
        emit EntityGenesis(origin);
    }

    /*
     *  @dev function to had a new proposal
     *  @dev CAN include ether to fund the proposal right away
     *  @param uint256 _lat first coordinate
     *  @param uint256 _lon second coordinate
     *  @return uint256 ID of the new proposal
     */
    function addProposal(uint256 _lat, uint256 _lon) payable public returns(uint256)
    {
        proposalCounter++;

        Proposal newProposal = new Proposal();
        newProposal.lat = _lat;
        newProposal.lon = _lon;

        if (msg.value > 0) {
            newProposal.balance = msg.value;
            emit ProposalFunded(proposalCounter, 0, msg.value, msg.sender);
        }

        proposals[proposalCounter] = newProposal;
        emit ProposalAdded(proposalCounter, _lat, _lon, msg.sender);
    }

    /*
     *  @dev function to add more funding to a proposal
     *  @param uint256 _id of the proposal someone is funding
     */
    function fundProposal(uint256 _id) payable public {
        require (!proposals[_id].finished);
        uint256 oldBalance = proposals[_id].balance;
        uint256 newBalance = oldBalance.add(msg.value);
        proposals[i].balance = newBalance;
        emit ProposalFunded(_id, oldBalance, newBalance, msg.sender);
    }

    /*
     *  @dev
     *  @param uint256 _id of the proposal someone is claiming
     *  @param uint256 current nonce read from the satellite
     *  @return bool always true
     */
    function claimProposal(uint256 _id, uint256 _nonce) isNotClaimed public returns(bool) {
        require (now - attemptTimestamp > 15 minutes);
        require (nonce != _nonce);
        attempting = msg.sender;
        attemptedClaimID = _id;
        attemptTimestamp = now;
        nonce = _nonce;
        emit ClaimAttemptSubmitted(_id, _nonce, msg.sender);
        return true;
    }

    /*
     *  @dev function to be send as a second confirmation of a nonce which should be checked by the satellite
     *  and followed up by calling acceptClaim() function to actually fix the claim as accepted;
     *  @param uint256 _id of the proposal
     *  @param uint256 _secondNonce the followup none which should differ from the previous nonce
     */
    function confirmClaim(uint256 _id, uint256 _secondNonce) isNotClaimed public {
        require(claimer == msg.sender);
        require (nonce < _secondNonce);
        nonce = _secondNonce;
        emit ClaimAttemptConfirmed(_id, _secondNonce, msg.sender);
    }

    // Functions only available for the satellite | OnlyOwner functions

    /*
     *  @dev function to payout the current proposal
     *  @return bool - always true
     */
    function payout() onlyOwner isClaimed public returns (bool) {
        uint256 total = claimedProposal.balance;
        uint256 satelite = total.multiply(SATELITE_PART).divide(100);
        uint256 dezentrum = total.multiply(DEZENTRUM_PART).divide(100);
        uint256 claimer = total.sub(satelite).sub(dezentrum);
        claimer.transfer(claimer);
        DECENTRUM_WALL.transfer(dezentrum);
        owner.transfer(satelite);
        claimedProposal.finished = true;
        claimedProposal.balance = 0;
        return true;
    }

    /*
     *  @dev function to be called as a reaction on claiming a proposal with a right nonce
     *  @param uint256 _id is the id of the currently attempted proposal in the `attemptedClaimID` variable
     *  @param address _claimer should be based on the reading of the 'attempting' variable
     */
    function approveClaim(uint256 _id, address _claimer) onlyOwner {
        require(attempting == _claimer);
        claimer = _claimer;
        emit ClaimApproved(_id, nonce, _claimer);
    }

    /*
     *  @dev
     *  @param uint256 _id is id of the currently handled proposal
     *  @param address of the party trying to claim a proposal
     */
    function acceptClaim(uint256 _id, address _claimer) onlyOwner {
        require(claimer == _claimer);
        claimedProposalID = _id;
        claimTime = now;
        emit ProposalClaimed(_id, nonce, claimTime, _claimer);
    }

    /*
     *  Helper functions
     */

    /*
     * @dev function to zero out the claimTime
     */
    function unclaim() onlyOwner {
        claimTime = 0;
    }

    /*
     *  @dev function returning details of a proposal
     *  @param uint256 _id is an id of a proposal to be checked
     *  @return uint256 lat - first coordinate
     *  @return uint256 lon - second coordinate
     *  @return uint256 balance associated with the proposal
     *  @return bool finished - logical toggle for the proposal state
     */
    function getProposal(uint256 _id) view public returns (uint256, uint256, uint256, bool ) {
        return (proposals[_id].lat, proposals[_id].lon, proposals[_id].balance, proposals[_id].finished);
    }

    /*
     *  Selfdestruct | Clean up
     */
    function selfDestruct() onlyOwner {
        emit SelfDestructInitiated('Silicon Heaven');
        selfdestruct(DECENTRUM_WALL);
    }
}