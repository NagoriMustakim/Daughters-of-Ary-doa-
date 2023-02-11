// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;
import "@openzeppelin/contracts/utils/Counters.sol";
import {Ownable} from "@openzeppelin/contracts/access/Ownable.sol";
import {ReentrancyGuard} from "@openzeppelin/contracts/security/ReentrancyGuard.sol";
import {ERC721} from "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import {ERC721URIStorage} from "@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol";
import {Pausable} from "@openzeppelin/contracts/security/Pausable.sol";
import {Strings} from "@openzeppelin/contracts/utils/Strings.sol";

contract NFT is Ownable, ReentrancyGuard, Pausable, ERC721URIStorage {
    using Strings for uint256;

    //counter variable
    uint256 public legendNFTCounter = 1;
    uint256 private rareNFTCounter;
    uint256 private UncommonNFTCounter;
    uint256 private commonNFTCounter;
    // pricing
    uint256 public legendNFT = 1.64 ether;
    uint256 public rareNFT = 0.33 ether;
    uint256 public UncommonNFT = 0.066 ether;
    uint256 public commonNFT = 0.013 ether;
    //state variable
    string private baseURI;
    string private baseExtension = ".json";
    address payable public publicFund;

    bool public firstPublicRound;
    bool public secondPublicRound;
    bool public thirdPublicRound;
    bool public isHeroMinted;
    bool public firstPublicRoundCompleted;

    //modifier
    modifier legendComplaince() {
        require(msg.value >= legendNFT, "Insufficient value");
        _;
    }

    constructor(
        string memory _name,
        string memory _symbol,
        string memory _initBaseURI,
        address payable _publicFund
    ) ERC721(_name, _symbol) {
        baseURI = _initBaseURI;
        publicFund = _publicFund;
    }

    function mintHero() public onlyOwner whenNotPaused nonReentrant {
        for (uint256 i = 0; i < 25; i++) {
            _safeMint(msg.sender, i);
        }
        isHeroMinted = true;
    }

    function mintLegend() public payable legendComplaince whenNotPaused {
        require(
            firstPublicRound || secondPublicRound || thirdPublicRound,
            "Round is not started, yet!"
        );
        if (firstPublicRound) {
            require(legendNFTCounter <= 1, "NFT minted already");
            _safeMint(msg.sender, 24 + legendNFTCounter);
            legendNFTCounter++;
            
        } else if (secondPublicRound) {
            require(legendNFTCounter <= 11, "all NFT minted in second round");

            _safeMint(msg.sender, 24 + legendNFTCounter);
            legendNFTCounter++;
            
        }
        else if(thirdPublicRound){
            require(legendNFTCounter <=91, "All nft minted in third round");
            _safeMint(msg.sender, 24 + legendNFTCounter);
            legendNFTCounter++;
        }
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

    function _baseURI() internal view virtual override returns (string memory) {
        return baseURI;
    }

    function startFirstPublicRound() external onlyOwner whenNotPaused {
        require(firstPublicRound != true, "first round is already started");
        require(isHeroMinted, "Hero NFT is not Minted yet!");
        firstPublicRound = true;
    }

    function startSecondPublicRound() external onlyOwner whenNotPaused {
        require(firstPublicRound != false, "First round is not started");
        require(secondPublicRound != true, "second round is already started");
        require(legendNFTCounter > 1, "not all nfts minted of first round");
        secondPublicRound = true;
        firstPublicRound = false;
    }

    function startThirdPublicRound() external onlyOwner whenNotPaused {
        require(secondPublicRound != false, "second round is not started");
        //need to check total nft are minted in second round or not
        require(legendNFTCounter > 11, "not all nfts minted of second round");
        thirdPublicRound = true;
         secondPublicRound = false;
    }

    function setBaseExtension(string memory _newBaseExtension)
        public
        onlyOwner
        whenNotPaused
    {
        baseExtension = _newBaseExtension;
    }

    function setInitialBaseUri(string memory _newBaseUri)
        public
        onlyOwner
        whenNotPaused
    {
        baseURI = _newBaseUri;
    }

    function pause() external whenNotPaused onlyOwner {
        _pause();
    }

    function unpause() external whenPaused onlyOwner {
        _unpause();
    }

    //need to set automatic = as soon as nft someone purchase nft, payment of that nft is going to split.
    function splitPayment(address payable daoContract)
        external
        onlyOwner
        whenNotPaused
        nonReentrant
    {
        uint256 balance = address(this).balance;
        daoContract.transfer((balance * 40) / 100);
        publicFund.transfer((balance * 60) / 100);
    }

    receive() external payable {}

    fallback() external payable {}
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
    address public publicFund;
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
    constructor(
        address payable _nft,
        address[] memory _founder,
        address _publicFund
    ) {
        nft = NFT(_nft);
        founders = _founder;
        publicFund = _publicFund;
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
