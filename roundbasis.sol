// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/Counters.sol";

contract MyNFTCollection is ERC721URIStorage, Ownable {
    using Counters for Counters.Counter;
    Counters.Counter private _tokenIdCounter;

    uint256 constant ROUND_ONE_SUPPLY = 20;
    uint256 constant ROUND_TWO_SUPPLY = 40;
    uint256 constant ROUND_THREE_SUPPLY = 30;
    uint256 constant TOTAL_SUPPLY =
        ROUND_ONE_SUPPLY + ROUND_TWO_SUPPLY + ROUND_THREE_SUPPLY;

    uint256 private _roundOneMinted;
    uint256 private _roundTwoMinted;
    uint256 private _roundThreeMinted;

    constructor() ERC721("MyNFTCollection", "MNC") {}

    function mint() public onlyOwner {
        require(
            ERC721.totalSupply() < TOTAL_SUPPLY,
            "All NFTs have been minted"
        );

        if (ERC721.totalSupply() < ROUND_ONE_SUPPLY) {
            _mintNFTs(ROUND_ONE_SUPPLY);
        } else if (ERC721.totalSupply() < ROUND_ONE_SUPPLY + ROUND_TWO_SUPPLY) {
            _mintNFTs(ROUND_TWO_SUPPLY);
        } else {
            _mintNFTs(ROUND_THREE_SUPPLY);
        }
    }

    function _mintNFTs(uint256 quantity) private {
        require(
            ERC721.totalSupply() < TOTAL_SUPPLY,
            "All NFTs have been minted"
        );
        require(
            ERC721.totalSupply() + quantity <= TOTAL_SUPPLY,
            "Mint quantity exceeds total supply"
        );

        uint256 i;
        for (i = 0; i < quantity; i++) {
            uint256 newTokenId = _getNextTokenId();
            _safeMint(msg.sender, newTokenId);
            _setTokenURI(
                newTokenId,
                "https://ipfs.io/ipfs/QmXWmCiM5PzTpZgdyJt1S63tR5cFfN4Y1Hej3qPU4Q2Bpw"
            );

            if (ERC721.totalSupply() < ROUND_ONE_SUPPLY) {
                _roundOneMinted++;
            } else if (
                ERC721.totalSupply() < ROUND_ONE_SUPPLY + ROUND_TWO_SUPPLY
            ) {
                _roundTwoMinted++;
            } else {
                _roundThreeMinted++;
            }
        }
    }

    function _getNextTokenId() private view returns (uint256) {
        return _tokenIdCounter.current() + 1;
    }
}
