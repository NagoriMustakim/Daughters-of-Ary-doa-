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


    //# sold NFTs
    uint256 public legendNFTCounter = 1;
    uint256 public rareNFTCounter = 1;
    uint256 public uncommonNFTCounter = 1;
    uint256 public commonNFTCounter = 1;

    // pricing
    uint256 public legendNFT = 1.64 ether; //~$2500
    uint256 public rareNFT = 0.33 ether; //~$500
    uint256 public uncommonNFT = 0.066 ether; //~$100
    uint256 public commonNFT = 0.013 ether; //~$20

    //state variable
    string private baseURI;
    string private baseExtension = ".json";
    address payable public publicFund;

    //round control
    bool public firstPublicRoundUnlocked;
    bool public secondPublicRoundUnlocked;
    bool public thirdPublicRoundUnlocked;
    bool public _isHeroMinted;

    //modifier
    modifier checkLegendNFTsAvailable() {
        require(msg.value >= legendNFT, "Insufficient value");
        _;
    }
    modifier checkRareNFTsAvailable() {
        require(msg.value >= rareNFT, "Insufficient value");
        _;
    }
    modifier checkUncommonNFTsAvailable() {
        require(msg.value >= uncommonNFT, "Insufficient value");
        _;
    }

    modifier checkCommonNFTsAvailable() {
        require(msg.value >= commonNFT, "Insufficient value");
        _;
    }


    constructor(
        string memory _name,
        string memory _symbol,
        string memory _initBaseURI,
        address payable _publicFund //address of public fund (should be this contract address)

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

    function mintLegend() external payable checkLegendNFTsAvailable whenNotPaused {
        require(
            firstPublicRoundUnlocked || secondPublicRoundUnlocked || thirdPublicRoundUnlocked,
            "Round is not started, yet!"
        );
        if (firstPublicRoundUnlocked) {
            require(legendNFTCounter <= 1, "All nft is minted in first round");
            _safeMint(msg.sender, 24 + legendNFTCounter);
            _totalMinted.increment();
            legendNFTCounter++;
        } else if (secondPublicRoundUnlocked) {
            require(legendNFTCounter <= 11, "All NFT minted in second round");
            _safeMint(msg.sender, 24 + legendNFTCounter);
            _totalMinted.increment();
            legendNFTCounter++;
        } else if (thirdPublicRoundUnlocked) {
            require(legendNFTCounter <= 91, "All nft minted in third round");
            _safeMint(msg.sender, 24 + legendNFTCounter);
            _totalMinted.increment();
            legendNFTCounter++;
        }
    }

    function mintRare() external payable checkRareNFTsAvailable whenNotPaused {
        require(
            firstPublicRoundUnlocked || secondPublicRoundUnlocked || thirdPublicRoundUnlocked,
            "Round is not started, yet!"
        );
        if (firstPublicRoundUnlocked) {
            require(rareNFTCounter <= 5, "All nft is minted in first round");
            _safeMint(msg.sender, 126 + rareNFTCounter);

            _totalMinted.increment();
            rareNFTCounter++;
        } else if (secondPublicRoundUnlocked) {
            require(rareNFTCounter <= 55, "All NFT minted in second round");

            _safeMint(msg.sender, 126 + rareNFTCounter);

            rareNFTCounter++;
            _totalMinted.increment();
        } else if (thirdPublicRoundUnlocked) {
            require(rareNFTCounter <= 455, "All nft minted in third round");
            _safeMint(msg.sender, 126 + rareNFTCounter);
            rareNFTCounter++;
            _totalMinted.increment();
        }
    }

    function mintUncommon() external payable checkRareNFTsAvailable whenNotPaused {
        require(
            firstPublicRoundUnlocked || secondPublicRoundUnlocked || thirdPublicRoundUnlocked,
            "Round is not started, yet!"
        );
        if (firstPublicRoundUnlocked) {
            require(
                uncommonNFTCounter <= 25,
                "All nft is minted in first round"
            );
            _safeMint(msg.sender, 626 + uncommonNFTCounter);
            _totalMinted.increment();
            uncommonNFTCounter++;
        } else if (secondPublicRoundUnlocked) {
            require(uncommonNFTCounter <= 55, "All NFT minted in second round");
            _safeMint(msg.sender, 626 + uncommonNFTCounter);
            uncommonNFTCounter++;
            _totalMinted.increment();
        } else if (thirdPublicRoundUnlocked) {
            require(uncommonNFTCounter <= 455, "All nft minted in third round");
            _safeMint(msg.sender, 626 + uncommonNFTCounter);
            uncommonNFTCounter++;
            _totalMinted.increment();
        }
    }

    function mintCommon() external payable checkRareNFTsAvailable whenNotPaused {
        require(
            firstPublicRoundUnlocked || secondPublicRoundUnlocked || thirdPublicRoundUnlocked,
            "Round is not started, yet!"
        );
        if (firstPublicRoundUnlocked) {
            require(
                commonNFTCounter <= 125,
                "All nft is minted in first round"
            );
            _safeMint(msg.sender, 3126 + commonNFTCounter);
            _totalMinted.increment();
            commonNFTCounter++;
        } else if (secondPublicRoundUnlocked) {
            require(commonNFTCounter <= 1250, "All NFT minted in second round");
            _safeMint(msg.sender, 3126 + commonNFTCounter);
            commonNFTCounter++;
            _totalMinted.increment();
        } else if (thirdPublicRoundUnlocked) {
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

    function startfirstPublicRoundUnlocked() external onlyOwner whenNotPaused {
        require(firstPublicRoundUnlocked != true, "first round is already started");
        require(_isHeroMinted, "Hero NFT is not Minted yet!");
        firstPublicRoundUnlocked = true;
    }

    function startsecondPublicRoundUnlocked() external onlyOwner whenNotPaused {
        require(firstPublicRoundUnlocked != false, "First round is not started");
        require(secondPublicRoundUnlocked != true, "second round is already started");
        require(
            _totalMinted.current() == 156,
            "not all nfts minted of first round"
        );
        secondPublicRoundUnlocked = true;
        firstPublicRoundUnlocked = false;
    }

    function startthirdPublicRoundUnlocked() external onlyOwner whenNotPaused {
        require(secondPublicRoundUnlocked != false, "second round is not started");
        //need to check total nft are minted in second round or not
        require(
            _totalMinted.current() == 1560,
            "not all nfts minted of second round"
        );
        thirdPublicRoundUnlocked = true;
        secondPublicRoundUnlocked = false;
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
