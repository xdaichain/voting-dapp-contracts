pragma solidity 0.6.7;
pragma experimental ABIEncoderV2;

import "@openzeppelin/contracts-ethereum-package/contracts/math/SafeMath.sol";

contract VotingSpace {
    using SafeMath for uint256;

    event ProposalCreated(uint256 id);
    event Voted(uint256 proposalId, address voter, uint256 optionId);

    uint256 constant MIN_VOTING_DURATION = 259200; // in seconds (3 days)
    uint256 constant MAX_VOTING_DURATION = 2592000; // in seconds (30 days)
    string public name;
    address[] public admins;

    struct Vote {
        address voter;
        uint256 optionId;
    }

    struct Proposal {
        string title;
        string description;
        string[] options;
        uint256 startTimestamp;
        uint256 duration;
        address creator;
    }

    Proposal[] public proposals;
    mapping (uint256 => Vote[]) votes;
    mapping (uint256 => mapping (address => uint256)) votesIndexes;

    constructor(string memory _name, address[] memory _admins) public {
        name = _name;
        admins = _admins;
    }

    function createProposal(
        string memory _title,
        string memory _description,
        string[] memory _options,
        uint256 _startTimestamp,
        uint256 _duration
    ) public { // not external, because "string[] calldata" throws an error on compilation
        require(
            _startTimestamp >= block.timestamp &&
            _duration >= MIN_VOTING_DURATION &&
            _duration <= MAX_VOTING_DURATION,
            "wrong start block number or duration"
        );
        Proposal memory newProposal = Proposal(_title, _description, _options, _startTimestamp, _duration, msg.sender);
        uint256 proposalId = proposals.length;
        proposals.push(newProposal);
        emit ProposalCreated(proposalId);
    }

    function vote(uint256 _proposalId, uint256 _optionId, address _voter) external {
        require(_proposalId < proposals.length, "no such proposal");
        Proposal storage proposal = proposals[_proposalId];
        require(
            block.timestamp >= proposal.startTimestamp &&
            block.timestamp <= proposal.startTimestamp.add(proposal.duration),
            "not a voting time"
        );
        // address voter = msg.sender;
        address voter = _voter;
        uint256 voteIndex = votesIndexes[_proposalId][voter];
        if (voteIndex < votes[_proposalId].length && votes[_proposalId][voteIndex].voter == voter) {
            votes[_proposalId][voteIndex].optionId = _optionId;
        } else {
            Vote memory newVote = Vote(voter, _optionId);
            voteIndex = votes[_proposalId].length;
            votes[_proposalId].push(newVote);
            votesIndexes[_proposalId][voter] = voteIndex;
        }
        emit Voted(_proposalId, voter, _optionId);
    }

    function getProposal(uint256 _id) external view returns (
        string memory title,
        string memory description,
        string[] memory options,
        uint256 startTimestamp,
        uint256 duration,
        address creator
    ) {
        return (
            proposals[_id].title,
            proposals[_id].description,
            proposals[_id].options,
            proposals[_id].startTimestamp,
            proposals[_id].duration,
            proposals[_id].creator
        );
    }
}
