// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";

contract MyDAO is ERC721 {
    // Define variables for DAO ownership, proposals, and crowdfunding campaign
    address public owner;
    uint public proposalCount;
    uint public fundingGoal;
    uint public fundingProgress;
    uint public campaignDuration;
    uint public campaignStart;
    mapping(uint => Proposal) public proposals;
    mapping(address => uint) public votes;
    
    // Define struct for proposals
    struct Proposal {
        uint id;
        string name;
        string description;
        uint votes;
        bool accepted;
    }
    
    // Define events for proposal and vote actions
    event ProposalAdded(uint id, string name);
    event ProposalVoted(uint id, address voter, uint votes);
    
    // Constructor function to initialize the DAO and NFT
    constructor(string memory name, string memory symbol, uint _fundingGoal, uint _campaignDuration) ERC721(name, symbol) {
        owner = msg.sender;
        proposalCount = 0;
        fundingGoal = _fundingGoal;
        fundingProgress = 0;
        campaignDuration = _campaignDuration;
        campaignStart = 0;
    }
    
    // Function to add a proposal to the DAO
    function addProposal(string memory name, string memory description) public {
        require(msg.sender == owner, "Only the owner can add a proposal.");
        proposalCount++;
        proposals[proposalCount] = Proposal(proposalCount, name, description, 0, false);
        emit ProposalAdded(proposalCount, name);
    }
    
    // Function to vote on a proposal
    function voteProposal(uint id, uint votes) public {
        require(votes > 0, "Votes must be greater than zero.");
        require(balanceOf(msg.sender) > 0, "You must own an NFT to vote.");
        require(id > 0 && id <= proposalCount, "Invalid proposal ID.");
        Proposal storage proposal = proposals[id];
        require(!proposal.accepted, "Proposal has already been accepted.");
        votes[id] += votes;
        emit ProposalVoted(id, msg.sender, votes);
    }
    
    // Function to start the crowdfunding campaign
    function startCampaign() public {
        require(msg.sender == owner, "Only the owner can start the campaign.");
        require(campaignStart == 0, "Campaign has already started.");
        campaignStart = block.timestamp;
    }
    
    // Function to contribute to the crowdfunding campaign
    function contribute() public payable {
        require(campaignStart > 0, "Campaign has not started."); 
        require(block.timestamp <= campaignStart + campaignDuration, "Campaign has ended.");
        fundingProgress += msg.value;
        require(fundingProgress <= fundingGoal, "Funding goal has been reached.");
    }
    
    // Function to withdraw funds if the campaign is successful
    function withdrawFunds() public {
        require(msg.sender == owner, "Only the owner can withdraw funds.");
        require(fundingProgress >= fundingGoal, "Funding goal has not been reached.");
        payable(owner).transfer(fundingProgress);
    }
}
