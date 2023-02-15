// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol";
import "@openzeppelin/contracts/security/Pausable.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/cryptography/draft-EIP712.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/draft-ERC721Votes.sol";
import "@openzeppelin/contracts/utils/Counters.sol";
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";

contract Arya is
    ERC721,
    ERC721URIStorage,
    Pausable,
    ReentrancyGuard,
    Ownable,
    EIP712,
    ERC721Votes
{
    using Counters for Counters.Counter;
    Counters.Counter public _totalMinted;
    //revenue split
    uint8 public constant PUBLIC_FUND_SPLIT = 60; //60%
    uint8 public constant PRIVATE_FUND_SPLIT = 40; //40%

    //# sold NFTs
    uint8 public HeroNFTCounter = 0;
    uint8 public legendNFTCounter = 0;

    //#  NFTs supply in the collection (1st 10K round)
    uint8 public constant HERO_NFT_SUPPLY = 25;
    uint8 public constant LEGEND_NFT_SUPPLY = 100;
    uint16 public constant RARE_NFT_SUPPLY = 500;
    uint16 public constant UNCOMMON_NFT_SUPPLY = 2500;
    uint16 public constant COMMON_NFT_SUPPLY = 6900;

    // pricing
    uint256 public legendNFTPrice = 1.64 ether; //~$2500
    uint256 public rareNFTPrice = 0.33 ether; //~$500
    uint256 public uncommonNFTPrice = 0.066 ether; //~$100
    uint256 public commonNFTPrice = 0.013 ether; //~$20

    //NFT supply in 1st public round
    uint8 public constant TOTAL_SUPPLY_ROUND_1 = 181;
    uint8 public constant HERO_NFT_SUPPLY_ROUND_1 = 25;
    //NFT supply in 2nd public round
    uint16 public TOTAL_SUPPLY_ROUND_2 = 1560;
    uint8 public HERO_NFT_SUPPLY_ROUND_2 = 0;
    uint8 public LEGEND_NFT_SUPPLY_ROUND_2 = 10;
    //round control
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

    //payment check
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

    constructor(string memory _name, string memory _symbol)
        ERC721(_name, _symbol)
        EIP712(_name, "1")
    {}

    function mintHero(address _to, string memory uri)
        external
        onlyOwner
        whenNotPaused
        nonReentrant
    {
        require(bytes(uri).length > 0, "URI is required");
        require(HeroNFTCounter <= HERO_NFT_SUPPLY, "All hero nft are minted");
        if(HeroNFTCounter == HERO_NFT_SUPPLY){
            _isHeroMinted = true; 
        }
        HeroNFTCounter++;
        _safeMint(_to, HeroNFTCounter); //for dao founders so that gas saved
        _setTokenURI(HeroNFTCounter, uri);
        _totalMinted.increment();
        idToType[_totalMinted.current()][HeroNFTCounter] = typeOfNFT.Hero;
       
    }

    function mintLegend(string memory uri)
        external
        onlyOwner
        whenNotPaused
        nonReentrant
    {
        require(bytes(uri).length > 0, "URI is required");
        require(
            is1stPublicRoundUnlocked ||
                is2ndPublicRoundUnlocked ||
                is3rdPublicRoundUnlocked,
            "No minting round is currently active!"
        );
        if (is1stPublicRoundUnlocked) {
            require(
                legendNFTCounter <= HERO_NFT_SUPPLY_ROUND_1,
                "No more Legend NFTs available in 1st round"
            );
            _safeMint(msg.sender, legendNFTCounter);
            _setTokenURI(legendNFTCounter, uri);
            _totalMinted.increment();
            idToType[_totalMinted.current()][legendNFTCounter] = typeOfNFT
                .Legend;
            HeroNFTCounter++;
        } else if (is2ndPublicRoundUnlocked) {
            require(
                legendNFTCounter <= LEGEND_NFT_SUPPLY_ROUND_2,
                "No more Legend NFTs available in 1st round"
            );
            _safeMint(msg.sender, legendNFTCounter);
            _setTokenURI(legendNFTCounter, uri);
            _totalMinted.increment();
            idToType[_totalMinted.current()][legendNFTCounter] = typeOfNFT
                .Legend;
            HeroNFTCounter++;
        }
    }

    function unlock1stPublicRound() external onlyOwner whenNotPaused {
        require(
            is1stPublicRoundUnlocked != true,
            "First round is already started"
        );
        require(
            _isHeroMinted,
            "Error: Hero NFTs must be minted before 1st Public Round"
        );
        is1stPublicRoundUnlocked = true;
    }

    function unlock2ndPublicRound() external onlyOwner whenNotPaused {
        require(
            is1stPublicRoundUnlocked != false,
            "1st Public round must be run first"
        );
        require(
            is2ndPublicRoundUnlocked != true,
            "2nd Public round is already started"
        );
        require(
            _totalMinted.current() == TOTAL_SUPPLY_ROUND_1,
            "The 1st Public round is not complete"
        );
        is2ndPublicRoundUnlocked = true;
        is1stPublicRoundUnlocked = false;
    }

    function unlock3rdPublicRound() external onlyOwner whenNotPaused {
        require(
            is2ndPublicRoundUnlocked != false,
            "second round is not started"
        );
        //need to check total nft are minted in second round or not
        require(
            _totalMinted.current() ==
                TOTAL_SUPPLY_ROUND_1 + TOTAL_SUPPLY_ROUND_2,
            "not all nfts minted of second round"
        );
        is3rdPublicRoundUnlocked = true;
        is2ndPublicRoundUnlocked = false;
    }

    function pause() public onlyOwner {
        _pause();
    }

    function unpause() public onlyOwner {
        _unpause();
    }

    // The following functions are overrides required by Solidity.

    function _afterTokenTransfer(
        address from,
        address to,
        uint256 tokenId,
        uint256 batchSize
    ) internal override(ERC721, ERC721Votes) {
        super._afterTokenTransfer(from, to, tokenId, batchSize);
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
}
