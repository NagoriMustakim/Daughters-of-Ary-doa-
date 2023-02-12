// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;
import "@openzeppelin/contracts/utils/Counters.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";
import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol";
import "@openzeppelin/contracts/security/Pausable.sol";
import "@openzeppelin/contracts/utils/Strings.sol";

contract aryaNFT is Ownable, ReentrancyGuard, Pausable, ERC721URIStorage {
    using Strings for uint256;
    using Counters for Counters.Counter;
    Counters.Counter public _totalMinted;
    //counter variable
    uint256 public legendNFTCounter = 1;
    uint256 public rareNFTCounter = 1;
    uint256 public UncommonNFTCounter = 1;
    uint256 public commonNFTCounter = 1;

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
    bool public _isHeroMinted;

    //modifier
    modifier legendComplaince() {
        require(msg.value >= legendNFT, "Insufficient value");
        _;
    }
    modifier rareComplaince() {
        require(msg.value >= rareNFT, "Insufficient value");
        _;
    }
    modifier uncommonComplaince() {
        require(msg.value >= UncommonNFT, "Insufficient value");
        _;
    }

    modifier commonComplaince() {
        require(msg.value >= commonNFT, "Insufficient value");
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
        require(!_isHeroMinted, "Hero has already been minted");
        for (uint256 i = 0; i < 25; i++) {
            _safeMint(msg.sender, i);
        }
        _isHeroMinted = true;
    }

    function mintLegend() external payable legendComplaince whenNotPaused {
        require(
            firstPublicRound || secondPublicRound || thirdPublicRound,
            "Round is not started, yet!"
        );
        if (firstPublicRound) {
            require(legendNFTCounter <= 1, "All nft is minted in first round");
            _safeMint(msg.sender, 24 + legendNFTCounter);
            _totalMinted.increment();
            legendNFTCounter++;
        } else if (secondPublicRound) {
            require(legendNFTCounter <= 11, "All NFT minted in second round");
            _safeMint(msg.sender, 24 + legendNFTCounter);
            _totalMinted.increment();
            legendNFTCounter++;
        } else if (thirdPublicRound) {
            require(legendNFTCounter <= 91, "All nft minted in third round");
            _safeMint(msg.sender, 24 + legendNFTCounter);
            _totalMinted.increment();
            legendNFTCounter++;
        }
    }

    function mintRare() external payable rareComplaince whenNotPaused {
        require(
            firstPublicRound || secondPublicRound || thirdPublicRound,
            "Round is not started, yet!"
        );
        if (firstPublicRound) {
            require(rareNFTCounter <= 5, "All nft is minted in first round");
            _safeMint(msg.sender, 126 + rareNFTCounter);

            _totalMinted.increment();
            rareNFTCounter++;
        } else if (secondPublicRound) {
            require(rareNFTCounter <= 55, "All NFT minted in second round");

            _safeMint(msg.sender, 126 + rareNFTCounter);

            rareNFTCounter++;
            _totalMinted.increment();
        } else if (thirdPublicRound) {
            require(rareNFTCounter <= 455, "All nft minted in third round");
            _safeMint(msg.sender, 126 + rareNFTCounter);
            rareNFTCounter++;
            _totalMinted.increment();
        }
    }

    function mintUncommon() external payable rareComplaince whenNotPaused {
        require(
            firstPublicRound || secondPublicRound || thirdPublicRound,
            "Round is not started, yet!"
        );
        if (firstPublicRound) {
            require(
                UncommonNFTCounter <= 25,
                "All nft is minted in first round"
            );
            _safeMint(msg.sender, 626 + UncommonNFTCounter);
            _totalMinted.increment();
            UncommonNFTCounter++;
        } else if (secondPublicRound) {
            require(UncommonNFTCounter <= 55, "All NFT minted in second round");
            _safeMint(msg.sender, 626 + UncommonNFTCounter);
            UncommonNFTCounter++;
            _totalMinted.increment();
        } else if (thirdPublicRound) {
            require(UncommonNFTCounter <= 455, "All nft minted in third round");
            _safeMint(msg.sender, 626 + UncommonNFTCounter);
            UncommonNFTCounter++;
            _totalMinted.increment();
        }
    }

    function mintCommon() external payable rareComplaince whenNotPaused {
        require(
            firstPublicRound || secondPublicRound || thirdPublicRound,
            "Round is not started, yet!"
        );
        if (firstPublicRound) {
            require(
                commonNFTCounter <= 125,
                "All nft is minted in first round"
            );
            _safeMint(msg.sender, 3126 + commonNFTCounter);
            _totalMinted.increment();
            commonNFTCounter++;
        } else if (secondPublicRound) {
            require(commonNFTCounter <= 1250, "All NFT minted in second round");
            _safeMint(msg.sender, 3126 + commonNFTCounter);
            commonNFTCounter++;
            _totalMinted.increment();
        } else if (thirdPublicRound) {
            require(commonNFTCounter <= 5770, "All nft minted in third round");
            _safeMint(msg.sender, 3126 + commonNFTCounter);
            commonNFTCounter++;
            _totalMinted.increment();
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
        require(_isHeroMinted, "Hero NFT is not Minted yet!");
        firstPublicRound = true;
    }

    function startSecondPublicRound() external onlyOwner whenNotPaused {
        require(firstPublicRound != false, "First round is not started");
        require(secondPublicRound != true, "second round is already started");
        require(
            _totalMinted.current() == 156,
            "not all nfts minted of first round"
        );
        secondPublicRound = true;
        firstPublicRound = false;
    }

    function startThirdPublicRound() external onlyOwner whenNotPaused {
        require(secondPublicRound != false, "second round is not started");
        //need to check total nft are minted in second round or not
        require(
            _totalMinted.current() == 1560,
            "not all nfts minted of second round"
        );
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

    function splitPayment(address payable daoContract)
        external
        onlyOwner
        whenNotPaused
        nonReentrant
    {
        uint256 balance = address(this).balance;
        uint256 daoShare = (balance * 40) / 100;
        daoContract.transfer(daoShare);
        publicFund.transfer(balance - daoShare);
    }

    receive() external payable {}

    fallback() external payable {}
}

contract dao is Ownable, Pausable, ReentrancyGuard {
    using Counters for Counters.Counter;

    //total applications in dao
    Counters.Counter private _applicationsCounter;

    //state varaible
    uint256 public security_premium = 0.013 ether;
    // address public founder1;
    // address public founder2;
    // address public founder3;
    // address public founder4;
    //or creatting an array of founders

    address[] public founders;
    //nft contract
    aryaNFT public nft;
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
    mapping(address => uint256) public maxPerweek;

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
    constructor(address payable _nft, address[] memory _founder) {
        nft = aryaNFT(_nft);
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
        maxPerweek[msg.sender] = block.timestamp;

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
