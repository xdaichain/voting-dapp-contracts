pragma solidity 0.6.7;
pragma experimental ABIEncoderV2;

import "@openzeppelin/contracts-ethereum-package/contracts/math/SafeMath.sol";

contract VotingSpace {
    using SafeMath for uint256;

    event ProposalCreated(uint256 id);
    event Voted(uint256 proposalId, address voter, uint256 optionId);

    uint256 constant MIN_VOTING_DURATION = 50000; // in blocks
    uint256 constant MAX_VOTING_DURATION = 500000; // in blocks
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
        uint256 startBlockNumber;
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
        uint256 _startBlockNumber,
        uint256 _duration
    ) public { // not external, because "string[] calldata" throws an error on compilation
        require(
            _startBlockNumber >= block.number &&
            _duration >= MIN_VOTING_DURATION &&
            _duration <= MAX_VOTING_DURATION,
            "wrong start block number or duration"
        );
        Proposal memory newProposal = Proposal(_title, _description, _options, _startBlockNumber, _duration, msg.sender);
        uint256 proposalId = proposals.length;
        proposals.push(newProposal);
        emit ProposalCreated(proposalId);
    }

    function vote(uint256 _proposalId, uint256 _optionId) external {
        require(_proposalId < proposals.length, "no such proposal");
        Proposal storage proposal = proposals[_proposalId];
        require(
            block.number >= proposal.startBlockNumber &&
            block.number <= proposal.startBlockNumber.add(proposal.duration),
            "not a voting time"
        );
        uint256 voteIndex = votesIndexes[_proposalId][msg.sender];
        if (votes[_proposalId][voteIndex].voter == msg.sender) {
            votes[_proposalId][voteIndex].optionId = _optionId;
        } else {
            Vote memory newVote = Vote(msg.sender, _optionId);
            voteIndex = votes[_proposalId].length;
            votes[_proposalId].push(newVote);
            votesIndexes[_proposalId][msg.sender] = voteIndex;
        }
        emit Voted(_proposalId, msg.sender, _optionId);
    }
}
