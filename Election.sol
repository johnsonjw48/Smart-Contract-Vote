pragma solidity 0.8.17;

import "@openzeppelin/contracts/access/Ownable.sol";

contract Election is Ownable {

    struct Voter {
        bool isRegistered;
        bool hasVoted;
        uint256 candidatId;
    }

    struct Candidat {
        string description;
        uint256 voteCount;
    }

    enum WorkflowStatus {
        RegisteringVoters,
        VotingSessionStarted,
        VotingSessionEnded,
        VotesTallied
    }

    WorkflowStatus public workflowStatus;
    uint256 private winningCandidatId;



    mapping(address => Voter) public voters;
   
    Candidat[] candidats;
  


    constructor () {
        candidats.push(Candidat("toto le magicien", 0));
        candidats.push(Candidat("sorciere", 0));
        candidats.push(Candidat("Renaissance", 0));
    }
    event VoterRegistered(address voterAddress);


    event WorkflowStatusChange(
        WorkflowStatus previousStatus,
        WorkflowStatus newStatus
    );

    event Voted(address voter, uint256 candidatId);

    modifier flowStatus(WorkflowStatus _status) {
        require(
            workflowStatus == _status,
            "You are not able to do this action right now"
        );
        _;
    }

    function registerVoters(address _voterAddress)
        public
        flowStatus(WorkflowStatus.RegisteringVoters)
        onlyOwner
    {
        require(
            !voters[_voterAddress].isRegistered,
            "This address is already in voters"
        );

        voters[_voterAddress].isRegistered = true;

        emit VoterRegistered(_voterAddress);
    }

    function startVotingSession()
        public
        flowStatus(WorkflowStatus.RegisteringVoters)
        onlyOwner
    {
        workflowStatus = WorkflowStatus.VotingSessionStarted;
        emit WorkflowStatusChange(
            WorkflowStatus.RegisteringVoters,
            WorkflowStatus.VotingSessionStarted
        );
    }

        function vote(uint256 _id)
        public
        flowStatus(WorkflowStatus.VotingSessionStarted)
    {
        require(voters[msg.sender].isRegistered, "You are not allowed to vote");
        require(!voters[msg.sender].hasVoted, "You have already voted");
        candidats[_id].voteCount += 1;
        voters[msg.sender].hasVoted = true;
        voters[msg.sender].candidatId = _id;

        emit Voted(msg.sender, _id);
    }

    function endVotingSession()
        public
        flowStatus(WorkflowStatus.VotingSessionStarted)
        onlyOwner
    {
        workflowStatus = WorkflowStatus.VotingSessionEnded;
        emit WorkflowStatusChange(
            WorkflowStatus.VotingSessionStarted,
            WorkflowStatus.VotingSessionEnded
        );
    }

     function votesTallied()
        public
        flowStatus(WorkflowStatus.VotingSessionEnded)
        onlyOwner
    {
        uint256 winningVoteCount = 0;
        for (uint256 c = 0; c < candidats.length; c++) {
            if (candidats[c].voteCount > winningVoteCount) {
                winningVoteCount = candidats[c].voteCount;
                winningCandidatId = c;
            }
        }
        workflowStatus = WorkflowStatus.VotesTallied;
        emit WorkflowStatusChange(
            WorkflowStatus.VotingSessionEnded,
            WorkflowStatus.VotesTallied
        );
    }

    function getWinner()
        public
        view
        flowStatus(WorkflowStatus.VotesTallied)
        returns (Candidat memory)
    {
        return candidats[winningCandidatId];
    }


}
