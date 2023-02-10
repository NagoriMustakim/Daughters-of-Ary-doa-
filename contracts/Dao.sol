// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;
import "@openzeppelin/contracts/utils/Counters.sol";
import {Ownable} from "@openzeppelin/contracts/access/Ownable.sol";
import {ReentrancyGuard} from "@openzeppelin/contracts/security/ReentrancyGuard.sol";
import {ERC721} from "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import {Pausable} from "@openzeppelin/contracts/security/Pausable.sol";
import {Strings} from "@openzeppelin/contracts/utils/Strings.sol";

contract NFT is ERC721, Ownable, ReentrancyGuard, Pausable {
    string private baseURI;
    string private baseExtension = ".json";
    address public founder;
    uint256 private tokenCounter = 1;
    bool private heroNFT;
    bool public firstPublicRound;
    // prcing
    uint256 public legendNFT = 1.54 ether;
    uint256 public rareNFT = 0.31 ether;
    uint256 public UncommonNFT = 0.062 ether;
    uint256 public commonNFT = 0.012 ether;

    constructor(
        string memory _name,
        string memory _symbol,
        address _founder,
        string memory _initBaseURI
    ) ERC721(_name, _symbol) {
        founder = _founder;
        baseURI = _initBaseURI;
    }

    //nft minting function
    function safeMint(uint256 tokenId) public onlyOwner {
        _safeMint(msg.sender, tokenId);
    }

    function tokenURI(uint256 tokenId)
        public
        view
        virtual
        override
        returns (string memory)
    {
        require(
            _exists(tokenId),
            "ERC721Metadata: URI query for nonexistent token"
        );
        string memory currentBaseURI = _baseURI();
        return
            bytes(currentBaseURI).length > 0
                ? string(
                    abi.encodePacked(
                        currentBaseURI,
                        Strings.toString(tokenId + 1),
                        baseExtension
                    )
                )
                : "";
    }

    function startFirstPublicRound() external onlyOwner whenNotPaused {
        firstPublicRound = true;
    }

    function pause() external whenNotPaused onlyOwner {
        _pause();
    }

    function unpause() external whenPaused onlyOwner {
        _unpause();
    }

    function setBaseURI(string memory _newBaseURI) public onlyOwner {
        baseURI = _newBaseURI;
    }

    function setBaseExtension(string memory _newBaseExtension)
        public
        onlyOwner
    {
        baseExtension = _newBaseExtension;
    }

    function updatedFounderAddress(address _newfounderAddress)
        public
        onlyOwner
    {
        founder = _newfounderAddress;
    }
}

contract dao is Ownable, Pausable {
    using Counters for Counters.Counter;

    //total applications in dao
    Counters.Counter private _applicationsCounter;
    //state varaible

    // address public founder1;
    // address public founder2;
    // address public founder3;
    // address public founder4;
    //or creatting an array of founders
    address[] public founders;
    //nft contract
    NFT public nft;
    //struct
    struct application {
        address payable applicant;
        uint256 id;
        uint256 amountRequired;
        uint256 votesUp;
        uint256 votesDown;
        uint256 deadline;
        bool totalVote;
        bool passed;
        bool exists;
        // bool counConducted;
        mapping(address => bool) voteStatus;
    }
    //mapping
    mapping(uint256 => application) public Applications; //id to application

    //modifier
    modifier checkApplicantEligibility(uint256 _tokenid) {
        require(
            msg.sender == nft.ownerOf(_tokenid),
            "Need to be an NFT holder"
        );
        _;
    }

    //constructor
    constructor(address _nft, address[] memory _founder) {
        nft = NFT(_nft);
        founders = _founder;
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
    function submitApplication(
        uint256 _amountRequired,
        uint256 _deadline,
        uint256 _tokenid
    ) public checkApplicantEligibility(_tokenid) whenNotPaused {
        application storage newApplication = Applications[
            _applicationsCounter.current()
        ];
        newApplication.id = _applicationsCounter.current();
        newApplication.exists = true;
        newApplication.deadline = block.number + _deadline;
        newApplication.amountRequired = _amountRequired;

        emit ApplicationsCreated(
            msg.sender,
            _applicationsCounter.current(),
            _amountRequired
        );
        _applicationsCounter.increment();
    }

    //vote an application
    function Vote(
        uint256 _id,
        bool _vote,
        uint256 _tokenid
    ) public checkApplicantEligibility(_tokenid) whenNotPaused {
        require(Applications[_id].exists, "This Proposal does not exist");
        require(
            !Applications[_id].voteStatus[msg.sender],
            "You have already voted on this Proposal"
        );
        require(
            block.number <= Applications[_id].deadline,
            "The deadline has passed for this Proposal"
        );
        application storage a = Applications[_id];
        if (_vote) {
            a.votesUp++;
        } else {
            a.votesDown++;
        }
        a.voteStatus[msg.sender] = true;
        emit newVote(a.votesUp, a.votesDown, _id, msg.sender, _vote);
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

    function pause() external whenNotPaused onlyOwner {
        _pause();
    }

    function unpause() external whenPaused onlyOwner {
        _unpause();
    }
}
