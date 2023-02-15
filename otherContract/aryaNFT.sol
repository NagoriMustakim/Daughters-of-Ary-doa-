// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;
import "@openzeppelin/contracts/utils/Counters.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";
import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol";
import "@openzeppelin/contracts/security/Pausable.sol";
import "@openzeppelin/contracts/utils/Strings.sol";

contract aryaNFT is
    ERC721,
    ERC721URIStorage,
    Ownable,
    ReentrancyGuard,
    Pausable
{
    using Strings for uint256;
    using Counters for Counters.Counter;
    Counters.Counter public _totalMinted;

    //# sold NFTs
    uint256 public legendNFTCounter;
    uint256 public rareNFTCounter;
    uint256 public uncommonNFTCounter;
    uint256 public commonNFTCounter;

    //#  NFTs supply in 1st 10K round
    uint256 public HERO_NFT_SUPPLY = 25;
    uint256 public LEGEND_NFT_SUPPLY = 1;
    uint256 public RARE_NFT_SUPPLY = 5;
    uint256 public UNCOMMON_NFT_SUPPLY = 25;
    uint256 public COMMON_NFT_SUPPLY = 125;

    //# pricing
    uint256 public legendNFTPrice = 1.64 ether; //~$2500
    uint256 public rareNFTPrice = 0.33 ether; //~$500
    uint256 public uncommonNFTPrice = 0.066 ether; //~$100
    uint256 public commonNFTPrice = 0.013 ether; //~$20

    //# state variable
    string public baseURIForHero;
    string public baseURIForLegend;
    string public baseURIForRare;
    string public baseURIForUncommon;
    string public baseURIForCommon;
    string private baseExtension = ".json";
    address payable public publicFund;

    //# round control
    bool public is1stPublicRoundUnlocked;
    bool public is2ndPublicRoundUnlocked;
    bool public is3rdPublicRoundUnlocked;
    bool public _isHeroMinted;

    //# NFT class
    enum typeOfNFT {
        Hero,
        Legend,
        Rare,
        Uncommon,
        Common
    }

    //# mapping
    mapping(uint256 => mapping(uint256 => typeOfNFT)) public idToType; //global id to type of nft or class of nft

    //modifier
    modifier checkLegendNFTPayment() {
        require(
            msg.value >= legendNFTPrice,
            "Insufficient value: Legend NFTs cost 1.64 ether"
        );
        _;
    }
    modifier checkRareNFTPayment() {
        require(
            msg.value >= rareNFTPrice,
            "Insufficient value: Rare NFTs cost 0.33 ether"
        );
        _;
    }
    modifier checkUncommonNFTPayment() {
        require(
            msg.value >= uncommonNFTPrice,
            "Insufficient value: Uncommon NFTs cost 0.066 ether"
        );
        _;
    }

    modifier checkCommonNFTPayment() {
        require(
            msg.value >= commonNFTPrice,
            "Insufficient value: Common NFTs cost 0.013 ether"
        );
        _;
    }

    constructor(
        string memory _name,
        string memory _symbol,
        address payable _publicFund, //address of public fund (should be this contract address)
        string memory _baseURIForHero,
        string memory _baseURIForLegend,
        string memory _baseURIForRare,
        string memory _baseURIForUncommon,
        string memory _baseURIForCommon
    ) ERC721(_name, _symbol) {
        publicFund = _publicFund;
        baseURIForHero = _baseURIForHero;
        baseURIForLegend = _baseURIForLegend;
        baseURIForRare = _baseURIForRare;
        baseURIForUncommon = _baseURIForUncommon;
        baseURIForCommon = _baseURIForCommon;
    }

    function mintHero(string[] memory uri)
        public
        onlyOwner
        whenNotPaused
        nonReentrant
    {
        require(uri.length == HERO_NFT_SUPPLY, "Provide all uri");
        require(!_isHeroMinted, "All 25 Heros have been minted");
        //id 1-25 NFTs
        for (uint256 i = 1; i <= HERO_NFT_SUPPLY; i++) {
            _safeMint(msg.sender, i);
            _setTokenURI(i, uri[i]);
            _totalMinted.increment();
            idToType[_totalMinted.current()][i] = typeOfNFT.Hero;
        }
        _isHeroMinted = true;
    }

    function mintLegend() external payable checkLegendNFTPayment whenNotPaused {
        require(
            is1stPublicRoundUnlocked ||
                is2ndPublicRoundUnlocked ||
                is3rdPublicRoundUnlocked,
            "Round is not started, yet!"
        );
        if (is1stPublicRoundUnlocked) {
            require(
                legendNFTCounter < LEGEND_NFT_SUPPLY,
                "All nft is minted in first round"
            );
            _safeMint(msg.sender, legendNFTCounter);
            _totalMinted.increment();
            legendNFTCounter++;
            idToType[_totalMinted.current()][legendNFTCounter] = typeOfNFT
                .Legend;
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
            is1stPublicRoundUnlocked ||
                is2ndPublicRoundUnlocked ||
                is3rdPublicRoundUnlocked,
            "Round is not started, yet!"
        );
        if (is1stPublicRoundUnlocked) {
            require(
                rareNFTCounter < RARE_NFT_SUPPLY,
                "All nft is minted in first round"
            );
            _safeMint(msg.sender, rareNFTCounter);
            _totalMinted.increment();
            rareNFTCounter++;
            idToType[_totalMinted.current()][rareNFTCounter] = typeOfNFT.Rare;
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
            is1stPublicRoundUnlocked ||
                is2ndPublicRoundUnlocked ||
                is3rdPublicRoundUnlocked,
            "Round is not started, yet!"
        );
        if (is1stPublicRoundUnlocked) {
            require(
                uncommonNFTCounter < UNCOMMON_NFT_SUPPLY,
                "All nft is minted in first round"
            );
            _safeMint(msg.sender, 626 + uncommonNFTCounter);
            _totalMinted.increment();
            uncommonNFTCounter++;
            idToType[_totalMinted.current()][uncommonNFTCounter] = typeOfNFT
                .Uncommon;
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
            is1stPublicRoundUnlocked ||
                is2ndPublicRoundUnlocked ||
                is3rdPublicRoundUnlocked,
            "Round is not started, yet!"
        );
        if (is1stPublicRoundUnlocked) {
            require(
                commonNFTCounter < COMMON_NFT_SUPPLY,
                "All nft is minted in first round"
            );
            _safeMint(msg.sender, commonNFTCounter);
            _totalMinted.increment();
            commonNFTCounter++;
            idToType[_totalMinted.current()][commonNFTCounter] = typeOfNFT.Rare;
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

    function _burn(uint256 tokenId)
        internal
        override(ERC721, ERC721URIStorage)
    {
        super._burn(tokenId);
    }

    function tokenURI(uint256 tokenId)
        public
        view
        override(ERC721, ERC721URIStorage)
        returns (string memory)
    {
        return super.tokenURI(tokenId);
    }

    function _baseURI() internal view virtual override returns (string memory) {
        return baseURIForHero;
    }

    function startfirstPublicRoundUnlocked() external onlyOwner whenNotPaused {
        require(
            is1stPublicRoundUnlocked != true,
            "first round is already started"
        );
        require(_isHeroMinted, "Hero NFT is not Minted yet!");
        is1stPublicRoundUnlocked = true;
    }

    function startsecondPublicRoundUnlocked() external onlyOwner whenNotPaused {
        require(
            is1stPublicRoundUnlocked != false,
            "First round is not started"
        );
        require(
            is2ndPublicRoundUnlocked != true,
            "second round is already started"
        );
        require(
            _totalMinted.current() == 156,
            "not all nfts minted of first round"
        );
        is2ndPublicRoundUnlocked = true;
        is1stPublicRoundUnlocked = false;
    }

    function startthirdPublicRoundUnlocked() external onlyOwner whenNotPaused {
        require(
            is2ndPublicRoundUnlocked != false,
            "second round is not started"
        );
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
        baseURIForHero = _newBaseUri;
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
