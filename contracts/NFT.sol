// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;
import {Ownable} from "@openzeppelin/contracts/access/Ownable.sol";
import {ReentrancyGuard} from "@openzeppelin/contracts/security/ReentrancyGuard.sol";
import {ERC721} from "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import {Counters} from "@openzeppelin/contracts/utils/Counters.sol";
import {Pausable} from "@openzeppelin/contracts/security/Pausable.sol";
import {Strings} from "@openzeppelin/contracts/utils/Strings.sol";

contract NFT is ERC721, Ownable, ReentrancyGuard, Pausable {
    //event
    event TransferTo(address indexed from, address indexed to, uint256 tokenid);

    //state veraible
    string private baseURI;
    string private baseExtension = ".json";
    address public founder;
    uint256 private tokenCounter = 1;
    bool private heroNFT;
    // prcing
    uint256 public legendNFT = 1.54 ether;
    uint256 public rareNFT = 0.31 ether;
    uint256 public UncommonNFT = 0.062 ether;
    uint256 public commonNFT = 0.012 ether;
    //mapping
    mapping(uint256 => mapping(bool => address)) public legendNFTToOwner;

    constructor(address _founder, string memory _initBaseURI)
        ERC721("HeroNFT", "HNFT")
    {
        founder = _founder;
        baseURI = _initBaseURI;
    }

    //modifier
    modifier HeroCounter() {
        require(tokenCounter <= 25, "All hero nft is minted");
        _;
    }
    modifier generalCounter() {
        require(heroNFT, "1st Round is not started, yet");
        require(tokenCounter > 25, "Hero nft need to mint first");
        _;
    }
    modifier legendCompilance() {
      
        require(msg.value >= legendNFT, "Insufficient funds to mint !!");
        _;
    }

    function mintHero() public onlyOwner nonReentrant whenNotPaused {
        uint256 increment = 1;
        for (uint256 i = 0; i < 25; i++) {
            _safeMint(msg.sender, i);
            increment++;
        }
        //gas saving tecnique
        tokenCounter = increment;
    }

    //public function
    function mintLegend()
        public
        payable
        generalCounter
        nonReentrant
        whenNotPaused
    {}

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
