// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;
import "@openzeppelin/contracts/utils/Counters.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";
import "@openzeppelin/contracts/security/Pausable.sol";
import "@openzeppelin/contracts/token/ERC721/IERC721.sol";

contract dao is Ownable, Pausable, ReentrancyGuard {
    using Counters for Counters.Counter;

    //total applications in dao
    Counters.Counter private _applicationsCounter;

    //state varaible
    uint256 public security_premium = 0.013 ether;
    address public founder1;
    address public founder2;
    address public founder3;
    address public founder4;
    //or creatting an array of founders

    //nft contract
    IERC721 nft;
    //struct
    struct application {
        address payable applicant;
        uint256 id;
        uint256 amountRequired;
        uint256 votesUp;
        uint256 votesDown;
        uint256 vetoUp;
        uint256 vetoDown;
        uint256 deadline;
        bool totalVote;
        bool vetoVote;
        bool passed;
        bool exists;
        string status;
        // bool counConducted;
        mapping(address => bool) voteStatus;
    }
    //mapping
    mapping(uint256 => application) public Applications; //id to application
    mapping(address => bool) public isBan;
    mapping(address => bool) public deList;
    mapping(address => uint16) public maxPerweek;

    //modifier
    modifier checkApplicantEligibility(uint256 _tokenid) {
        require(
            msg.sender == nft.ownerOf(_tokenid),
            "You are not owner of provided tokenid, yet you can't submit application!"
        );

        require(msg.value >= security_premium, "Insufficient security premium");
        require(
            maxPerweek[msg.sender] <= 1 minutes, //just for testing porpose
            "maximum one application can submit in week"
        );
        require(
            isBan[msg.sender],
            "You are ban, You can't submit application any more"
        );
        require(
            deList[msg.sender],
            "You are de listed, You can't submit application any more"
        );

        _;
    }
    modifier checkVoteEligibility(uint256 _tokenid) {
        require(
            msg.sender == nft.ownerOf(_tokenid),
            "You are not owner of provided tokenid, yet you can't Vote on application!"
        );

        _;
    }

    //constructor
    constructor(
        address payable _nft,
        address _founter1,
        address _founter2,
        address _founter3,
        address _founter4
    ) {
        nft = IERC721(_nft);
        founder1 = _founter1;
        founder2 = _founter2;
        founder3 = _founter3;
        founder4 = _founter4;
        _applicationsCounter.increment();
    }

    //events
    event ApplicationsCreated(
        address indexed applicantAddress,
        uint256 id,
        uint256 amountRequired
    );
    event newVote(
        uint256 votesUp,
        uint256 votesDown,
        uint256 id,
        address voter,
        bool votedFor
    );

    event ApplicationsCounted(uint256 id, bool passed);

    //nft holder function
    function submitApplication(uint256 _amountRequired, uint256 _tokenid)
        public
        payable
        checkApplicantEligibility(_tokenid)
        whenNotPaused
    {
        application storage newApplication = Applications[
            _applicationsCounter.current()
        ];
        newApplication.id = _applicationsCounter.current();
        newApplication.exists = true;
        newApplication.deadline = block.number + 1 weeks;
        newApplication.amountRequired = _amountRequired;
        maxPerweek[msg.sender] = uint16(block.timestamp);

        emit ApplicationsCreated(
            msg.sender,
            _applicationsCounter.current(),
            _amountRequired
        );
        _applicationsCounter.increment();
    }

    //vote an application
    function Vote(
        uint256 _tokenid,
        uint256 _ApplicationId,
        bool _vote
    ) public checkVoteEligibility(_tokenid) whenNotPaused {
        require(
            Applications[_ApplicationId].exists,
            "This Proposal does not exist"
        );
        require(
            !Applications[_ApplicationId].voteStatus[msg.sender],
            "You have already voted on this Proposal"
        );
        require(
            block.number <= Applications[_ApplicationId].deadline,
            "The deadline has passed for this Proposal"
        );
        application storage a = Applications[_ApplicationId];
        if (_vote) {
            if (_tokenid < 25) {
                a.vetoUp += 250;
            } else if (_tokenid < 126) {
                a.votesUp += 125;
            } else if (_tokenid < 627) {
                a.votesUp += 25;
            } else if (_tokenid < 3128) {
                a.votesUp += 5;
            } else {
                a.votesUp++;
            }
        } else {
            if (_tokenid < 25) {
                a.vetoDown += 250;
            } else if (_tokenid < 126) {
                a.votesDown += 125;
            } else if (_tokenid < 627) {
                a.votesDown += 25;
            } else if (_tokenid < 3128) {
                a.votesDown += 5;
            } else {
                a.votesDown++;
            }
        }
        a.voteStatus[msg.sender] = true;
        emit newVote(a.votesUp, a.votesDown, _ApplicationId, msg.sender, _vote);
    }

    function TotalVeto(uint256 _applicationId) public onlyOwner whenNotPaused {
        require(
            Applications[_applicationId].exists,
            "This Proposal does not exist"
        );
        require(
            block.number > Applications[_applicationId].deadline,
            "Voting has not concluded"
        );
        require(
            !Applications[_applicationId].vetoVote,
            "vetoVote already conducted"
        );
        application storage a = Applications[_applicationId];
        if (
            Applications[_applicationId].vetoDown <
            Applications[_applicationId].vetoUp
        ) {
            a.passed = true;
            //need to return $20 security premium
        } else {
            //ban nft and A premium ($20) is taken as penalty
            banMemeber();
            delistNFT();
            a.passed = false;
        }
    }

    function TotalVotes(uint256 _id) public onlyOwner whenNotPaused {
        require(Applications[_id].exists, "This Proposal does not exist");
        require(
            block.number > Applications[_id].deadline,
            "Voting has not concluded"
        );
        require(!Applications[_id].totalVote, "totalVote already conducted");
        application storage a = Applications[_id];
        if (Applications[_id].votesDown < Applications[_id].votesUp) {
            a.passed = true;
        }
        a.totalVote = true; //means total vote is counted for that particular applications
        emit ApplicationsCounted(_id, a.passed);
    }

    function delistNFT() internal returns (bool) {}

    function banMemeber() internal {}

    function relist() public {}

    function unban() public {}

    function pause() external whenNotPaused onlyOwner {
        _pause();
    }

    function unpause() external whenPaused onlyOwner {
        _unpause();
    }

    receive() external payable {}

    fallback() external payable {}
}
