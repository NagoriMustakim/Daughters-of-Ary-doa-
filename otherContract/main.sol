// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;
import "@openzeppelin/contracts/utils/Counters.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";
import "@openzeppelin/contracts/security/Pausable.sol";
import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol";

contract HeroNFT is Ownable, ReentrancyGuard, Pausable, ERC721URIStorage {
    //
    uint256 public HERO_NFT_SUPPLY = 25;
    string private baseExtension = ".json";
    string public baseURIForHero;
    address private _caller;

    constructor(
        string memory _name,
        string memory _symbol,
        string memory _baseURIForHero
    ) ERC721(_name, _symbol) {
        baseURIForHero = _baseURIForHero;
    }

    modifier onlyMainContract(address _callerAddress) {
        require(_callerAddress != address(0), "Adress can't be null");
        require(_caller == _callerAddress, "caller is not main contract owner");
        _;
    }

    function mintHero(address _mainContractAddress)
        public
        onlyMainContract(_mainContractAddress)
        whenNotPaused
        nonReentrant
    {
        //id 1-25 NFTs
        for (uint256 i = 1; i <= HERO_NFT_SUPPLY; i++) {
            _safeMint(msg.sender, i);
        }
    }

    function setMainContractAddress(address _mainContractAddress)
        public
        onlyOwner
        whenNotPaused
    {
        _caller = _mainContractAddress;
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
                        Strings.toString(tokenId),
                        baseExtension
                    )
                )
                : "";
    }

    function _baseURI() internal view virtual override returns (string memory) {
        return baseURIForHero;
    }

    function setBaseExtension(string memory _newBaseExtension)
        public
        onlyOwner
        whenNotPaused
    {
        baseExtension = _newBaseExtension;
    }

    function setInitialBaseUri(string memory _newbaseURIForHero)
        public
        onlyOwner
        whenNotPaused
    {
        baseURIForHero = _newbaseURIForHero;
    }

    function pause() external whenNotPaused onlyOwner {
        _pause();
    }

    function unpause() external whenPaused onlyOwner {
        _unpause();
    }
}

contract main is Ownable, ReentrancyGuard, Pausable {
    //Interfaces
    HeroNFT public heroNFTContract;

    using Counters for Counters.Counter;
    Counters.Counter public _totalMinted;
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
    mapping(uint256 => mapping(uint256 => typeOfNFT)) public idToType;

    //#contructor
    constructor(address _heroNFTContractAddress) {
        heroNFTContract = HeroNFT(_heroNFTContractAddress);
    }

    function mintHero() public onlyOwner whenNotPaused nonReentrant {
        require(!_isHeroMinted, "All 25 Heros have been minted");
        heroNFTContract.mintHero(msg.sender);
        for (uint256 i = 1; i <= 25; i++) {
            _totalMinted.increment();
            idToType[_totalMinted.current()][i] = typeOfNFT.Hero;
        }
    }
}
