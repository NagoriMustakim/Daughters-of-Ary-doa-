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

    //#  NFTs supply in 1st 10K round
    uint256 public HERO_NFT_SUPPLY = 25;
    uint256 public LEGEND_NFT_SUPPLY = 1;
    uint256 public RARE_NFT_SUPPLY = 1;
    uint256 public UNCOMMON_NFT_SUPPLY = 1;
    uint256 public COMMON_NFT_SUPPLY = 1;

    // pricing
    uint256 public legendNFTPrice = 1.64 ether; //~$2500
    uint256 public rareNFTPrice = 0.33 ether; //~$500
    uint256 public uncommonNFTPrice = 0.066 ether; //~$100
    uint256 public commonNFTPrice = 0.013 ether; //~$20

    //state variable
    string private baseURI;
    string private baseExtension = ".json";
    address payable public publicFund;

    //round control
    bool public is1stPublicRoundUnlocked;
    bool public is2ndPublicRoundUnlocked;
    bool public is3rdPublicRoundUnlocked;
    bool public _isHeroMinted;

    //payment check
    modifier checkLegendNFTPayment() {
        require(msg.value >= legendNFTPrice , "Insufficient value: Legend NFTs cost " & legendNFTPrice & " ether" );
        _;
    }
    modifier checkRareNFTPayment() {
        require(msg.value >= rareNFTPrice, "Insufficient value: Rare NFTs cost " & rareNFTPrice & " ether");
        _;
    }
    modifier checkUncommonNFTPayment() {
        require(msg.value >= uncommonNFTPrice, "Insufficient value: Uncommon NFTs cost " & uncommonNFTPrice & " ether");
        _;
    }

    modifier checkCommonNFTPayment() {
        require(msg.value >= commonNFTPrice, "Insufficient value: Common NFTs cost " & commonNFTPrice & " ether");
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
        require(!_isHeroMinted, "All " & HERO_NFT_SUPPLY & " Heros have been minted");

        //id 1-25 NFTs
        for (uint256 i = 1; i <= HERO_NFT_SUPPLY ; i++) {
            _safeMint(msg.sender, i);
        }
        _isHeroMinted = true;
    }

    function mintLegend() external payable checkLegendNFTPayment whenNotPaused {
        require(
            is1stPublicRoundUnlocked || is2ndPublicRoundUnlocked || is3rdPublicRoundUnlocked,
            "Round is not started, yet!"
        );
        if (is1stPublicRoundUnlocked) {
            require(legendNFTCounter <= 1, "All nft is minted in first round");
            _safeMint(msg.sender, 24 + legendNFTCounter);
            _totalMinted.increment();
            legendNFTCounter++;
        } else if (is2ndPublicRoundUnlocked) {
            require(legendNFTCounter <= 11, "All NFT minted in second round");
            _safeMint(msg.sender, 24 + legendNFTCounter);
            _totalMinted.increment();
            legendNFTCounter++;
        } else if (is3rdPublicRoundUnlocked) {
            require(legendNFTCounter <= 91, "All nft minted in third round");
            _safeMint(msg.sender, 24 + legendNFTCounter);
            _totalMinted.increment();
            legendNFTCounter++;
        }
    }

    function mintRare() external payable checkRareNFTPayment whenNotPaused {
        require(
            is1stPublicRoundUnlocked || is2ndPublicRoundUnlocked || is3rdPublicRoundUnlocked,
            "Round is not started, yet!"
        );
        if (is1stPublicRoundUnlocked) {
            require(rareNFTCounter <= 5, "All nft is minted in first round");
            _safeMint(msg.sender, 126 + rareNFTCounter);

            _totalMinted.increment();
            rareNFTCounter++;
        } else if (is2ndPublicRoundUnlocked) {
            require(rareNFTCounter <= 55, "All NFT minted in second round");

            _safeMint(msg.sender, 126 + rareNFTCounter);

            rareNFTCounter++;
            _totalMinted.increment();
        } else if (is3rdPublicRoundUnlocked) {
            require(rareNFTCounter <= 455, "All nft minted in third round");
            _safeMint(msg.sender, 126 + rareNFTCounter);
            rareNFTCounter++;
            _totalMinted.increment();
        }
    }

    function mintUncommon() external payable checkRareNFTPayment whenNotPaused {
        require(
            is1stPublicRoundUnlocked || is2ndPublicRoundUnlocked || is3rdPublicRoundUnlocked,
            "Round is not started, yet!"
        );
        if (is1stPublicRoundUnlocked) {
            require(
                uncommonNFTCounter <= 25,
                "All nft is minted in first round"
            );
            _safeMint(msg.sender, 626 + uncommonNFTCounter);
            _totalMinted.increment();
            uncommonNFTCounter++;
        } else if (is2ndPublicRoundUnlocked) {
            require(uncommonNFTCounter <= 55, "All NFT minted in second round");
            _safeMint(msg.sender, 626 + uncommonNFTCounter);
            uncommonNFTCounter++;
            _totalMinted.increment();
        } else if (is3rdPublicRoundUnlocked) {
            require(uncommonNFTCounter <= 455, "All nft minted in third round");
            _safeMint(msg.sender, 626 + uncommonNFTCounter);
            uncommonNFTCounter++;
            _totalMinted.increment();
        }
    }

    function mintCommon() external payable checkRareNFTPayment whenNotPaused {
        require(
            is1stPublicRoundUnlocked || is2ndPublicRoundUnlocked || is3rdPublicRoundUnlocked,
            "Round is not started, yet!"
        );
        if (is1stPublicRoundUnlocked) {
            require(
                commonNFTCounter <= 125,
                "All nft is minted in first round"
            );
            _safeMint(msg.sender, 3126 + commonNFTCounter);
            _totalMinted.increment();
            commonNFTCounter++;
        } else if (is2ndPublicRoundUnlocked) {
            require(commonNFTCounter <= 1250, "All NFT minted in second round");
            _safeMint(msg.sender, 3126 + commonNFTCounter);
            commonNFTCounter++;
            _totalMinted.increment();
        } else if (is3rdPublicRoundUnlocked) {
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
        require(is1stPublicRoundUnlocked != true, "first round is already started");
        require(_isHeroMinted, "Hero NFT is not Minted yet!");
        is1stPublicRoundUnlocked = true;
    }

    function startsecondPublicRoundUnlocked() external onlyOwner whenNotPaused {
        require(is1stPublicRoundUnlocked != false, "First round is not started");
        require(is2ndPublicRoundUnlocked != true, "second round is already started");
        require(
            _totalMinted.current() == 156,
            "not all nfts minted of first round"
        );
        is2ndPublicRoundUnlocked = true;
        is1stPublicRoundUnlocked = false;
    }

    function startthirdPublicRoundUnlocked() external onlyOwner whenNotPaused {
        require(is2ndPublicRoundUnlocked != false, "second round is not started");
        //need to check total nft are minted in second round or not
        require(
            _totalMinted.current() == 1560,
            "not all nfts minted of second round"
        );
        is3rdPublicRoundUnlocked = true;
        is2ndPublicRoundUnlocked = false;
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
