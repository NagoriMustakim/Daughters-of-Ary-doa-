// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/security/ReentrancyGuard.sol";
import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol";
import "@openzeppelin/contracts/security/Pausable.sol";
import "@openzeppelin/contracts/utils/Strings.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

interface IHeroNFT {
    function mintHero() external;
}

contract HeroNFT is Ownable, ReentrancyGuard, Pausable, ERC721URIStorage {
    //
    uint256 public HERO_NFT_SUPPLY = 25;
    string private baseExtension = ".json";
    string public baseURIForHero;

    constructor(
        string memory _name,
        string memory _symbol,
        string memory _baseURIForHero
    ) ERC721(_name, _symbol) {
        baseURIForHero = _baseURIForHero;
    }

    function mintHero() public onlyOwner whenNotPaused nonReentrant {
        //id 1-25 NFTs
        for (uint256 i = 1; i <= HERO_NFT_SUPPLY; i++) {
            _safeMint(msg.sender, i);
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
