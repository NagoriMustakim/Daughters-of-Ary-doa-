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
