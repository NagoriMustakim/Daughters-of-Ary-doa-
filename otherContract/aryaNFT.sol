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

    //#  NFTs supply in 1st round
    uint256 public HERO_NFT_SUPPLY_1st = 25;
    uint256 public LEGEND_NFT_SUPPLY_1st = 1;
    uint256 public RARE_NFT_SUPPLY_1st = 5;
    uint256 public UNCOMMON_NFT_SUPPLY_1st = 25;
    uint256 public COMMON_NFT_SUPPLY_1st = 125;

    //#  NFTs supply in 2nd round
    uint256 public HERO_NFT_SUPPLY_2nd = 0;
    uint256 public LEGEND_NFT_SUPPLY_2nd = 10;
    uint256 public RARE_NFT_SUPPLY_2nd = 50;
    uint256 public UNCOMMON_NFT_SUPPLY_2nd = 250;
    uint256 public COMMON_NFT_SUPPLY_2nd = 1250;

    //#  NFTs supply in 3rd round
    uint256 public HERO_NFT_SUPPLY_3rd = 0;
    uint256 public LEGEND_NFT_SUPPLY_3rd = 80;
    uint256 public RARE_NFT_SUPPLY_3rd = 400;
    uint256 public UNCOMMON_NFT_SUPPLY_3rd = 2000;
    uint256 public COMMON_NFT_SUPPLY_3rd = 5770;

    //#  NFTs supply totals
    uint256 public NFT_SUPPLY_1st = 181;
    uint256 public NFT_SUPPLY_2nd = 1560;
    uint256 public NFT_SUPPLY_3rd = 8250;


    //#  NFT Type start indexes
    uint256 public HERO_NFT_START_INDEX = 1;
    uint256 public LEGEND_NFT_START_INDEX = 26;
    uint256 public RARE_NFT_START_INDEX = 127;
    uint256 public UNCOMMON_START_INDEX = 628;
    uint256 public COMMON_START_INDEX = 3129;

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
    mapping(uint256 => mapping(uint256 => typeOfNFT)) public collectionIDToNFTType; //global id to type of nft or class of nft

    //modifier
    modifier checkLegendNFTPayment() {
        require(
            msg.value >= legendNFTPrice,
            "Insufficient value: Legend NFTs cost " & legendNFTPrice & " ether"
        );
        _;
    }
    modifier checkRareNFTPayment() {
        require(
            msg.value >= rareNFTPrice,
            "Insufficient value: Rare NFTs cost " & rareNFTPrice & " ether"
        );
        _;
    }
    modifier checkUncommonNFTPayment() {
        require(
            msg.value >= uncommonNFTPrice,
            "Insufficient value: Uncommon NFTs cost " & uncommonNFTPrice & " ether"
        );
        _;
    }

    modifier checkCommonNFTPayment() {
        require(
            msg.value >= commonNFTPrice,
            "Insufficient value: Common NFTs cost " & commonNFTPrice & " ether"
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
        require(uri.length == HERO_NFT_SUPPLY, "Provide all URI");
        require(!_isHeroMinted, "All " & HERO_NFT_SUPPLY & " Heros have been minted");
        //id 1-25 NFTs
        for (uint256 i = HERO_NFT_START_INDEX; i <= HERO_NFT_SUPPLY_1st; i++) {
            _safeMint(msg.sender, i);
            _setTokenURI(i, uri[i]);
            _totalMinted.increment();
            collectionIDToNFTType[_totalMinted.current()][i] = typeOfNFT.Hero;
        }
        _isHeroMinted = true;
    }

    function mintLegend() external payable checkLegendNFTPayment whenNotPaused {
        //check round open
        require(
            is1stPublicRoundUnlocked || is2ndPublicRoundUnlocked || is3rdPublicRoundUnlocked,
            "Round is not started yet"
        );

        //check supply exists
        require(is1stPublicRoundUnlocked && legendNFTCounter < LEGEND_NFT_SUPPLY_1st, "All Legend NFTs are minted for the 1st public round");
        require(is2ndPublicRoundUnlocked && legendNFTCounter < LEGEND_NFT_SUPPLY_2nd, "All Legend NFTs are minted for the 2nd public round");
        require (is3rdPublicRoundUnlocked&& legendNFTCounter < LEGEND_NFT_SUPPLY_3rd, "All Legend NFTs are minted for the 3rd public round");

        //mint
        _safeMint(msg.sender, LEGEND_NFT_START_INDEX + legendNFTCounter);
        _totalMinted.increment();
        collectionIDToNFTType[_totalMinted.current()][legendNFTCounter] = typeOfNFT.Legend;

        legendNFTCounter++;
    }

    function mintRare() external payable checkRareNFTPayment whenNotPaused {
        //check round open
        require(
            is1stPublicRoundUnlocked || is2ndPublicRoundUnlocked || is3rdPublicRoundUnlocked,
            "Round is not started yet"
        );
        
        //check supply exists
        require(is1stPublicRoundUnlocked && rareNFTCounter < RARE_NFT_SUPPLY_1st, "All Rare NFTs are minted for the 1st public round");
        require(is2ndPublicRoundUnlocked && rareNFTCounter < RARE_NFT_SUPPLY_1st, "All Rare NFTs are minted for the 2nd public round");
        require (is3rdPublicRoundUnlocked&& rareNFTCounter < RARE_NFT_SUPPLY_1st, "All Rare NFTs are minted for the 3rd public round");

        //mint
        _safeMint(msg.sender, RARE_NFT_START_INDEX + rareNFTCounter);
        _totalMinted.increment();
        collectionIDToNFTType[_totalMinted.current()][rareNFTCounter] = typeOfNFT.Rare;

        rareNFTCounter++;
    }

    function mintUncommon() external payable checkUncommonNFTPayment whenNotPaused {
        //check round open
        require(
            is1stPublicRoundUnlocked || is2ndPublicRoundUnlocked || is3rdPublicRoundUnlocked,
            "Round is not started yet"
        );
        
        //check supply exists
        require(is1stPublicRoundUnlocked && uncommonNFTCounter < UNCOMMON_NFT_SUPPLY_1st, "All Uncommon NFTs are minted for the 1st public round");
        require(is2ndPublicRoundUnlocked && uncommonNFTCounter < UNCOMMON_NFT_SUPPLY_1st, "All Uncommon NFTs are minted for the 2nd public round");
        require (is3rdPublicRoundUnlocked&& uncommonNFTCounter < UNCOMMON_NFT_SUPPLY_1st, "All Uncommon NFTs are minted for the 3rd public round");

        //mint
        _safeMint(msg.sender, UNCOMMON_NFT_START_INDEX + uncommonNFTCounter);
        _totalMinted.increment();
        collectionIDToNFTType[_totalMinted.current()][uncommonNFTCounter] = typeOfNFT.Uncommon;
        
        uncommonNFTCounter++;
    }

    function mintcommon() external payable checkCommonNFTPayment whenNotPaused {
        //check round open
        require(
            is1stPublicRoundUnlocked || is2ndPublicRoundUnlocked || is3rdPublicRoundUnlocked,
            "Round is not started yet"
        );
        
        //check supply exists
        require(is1stPublicRoundUnlocked && commonNFTCounter < COMMON_NFT_SUPPLY_1st, "All Common NFTs are minted for the 1st public round");
        require(is2ndPublicRoundUnlocked && commonNFTCounter < COMMON_NFT_SUPPLY_1st, "All Common NFTs are minted for the 2nd public round");
        require (is3rdPublicRoundUnlocked&& commonNFTCounter < COMMON_NFT_SUPPLY_1st, "All Common NFTs are minted for the 3rd public round");

        //mint
        _safeMint(msg.sender, COMMON_NFT_START_INDEX + commonNFTCounter);
        _totalMinted.increment();
        collectionIDToNFTType[_totalMinted.current()][commonNFTCounter] = typeOfNFT.Common;
        
        commonNFTCounter++;
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

    function unlock1stPublicRound() external onlyOwner whenNotPaused {
        require(
            is1stPublicRoundUnlocked != true,
            "1st round is already started"
        );
        require(_isHeroMinted, "Hero NFT is not Minted yet!");

        is1stPublicRoundUnlocked = true;
    }

    function unlock2ndPublicRound() external onlyOwner whenNotPaused {
        require(
            is1stPublicRoundUnlocked != false,
            "First round is not started"
        );
        require(
            is2ndPublicRoundUnlocked != true,
            "2nd round is already started"
        );
        require(
            _totalMinted.current() == 156,
            "not all nfts minted of 1st round"
        );
        is2ndPublicRoundUnlocked = true;
        is1stPublicRoundUnlocked = false;
    }

    function unlock3rdPublicRound() external onlyOwner whenNotPaused {
        require(
            is2ndPublicRoundUnlocked != false,
            "2nd round is not started"
        );
        //need to check total nft are minted in 2nd round or not
        require(
            _totalMinted.current() == 1560,
            "not all nfts minted of 2nd round"
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
