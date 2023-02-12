// SPDX-License-Identifier: MIT 

pragma solidity ^0.8.0;
// import "./IERC721.sol"; 

contract NFTBanning {
    address public owner;
    IERC721 public nftContract;
    mapping(uint256 => bool) public bannedTokens;

    constructor(address _nftAddress) {
        owner = msg.sender;
        nftContract = IERC721(_nftAddress);
    }

    function banToken(uint256 _tokenId) public {
        require(msg.sender == owner, "Only the owner can ban tokens.");
        require(!bannedTokens[_tokenId], "Token is already banned.");
        nftContract.transferFrom(msg.sender, address(this), _tokenId);
        bannedTokens[_tokenId] = true;
    }

    function unbanToken(uint256 _tokenId) public {
        require(msg.sender == owner, "Only the owner can unban tokens.");
        require(bannedTokens[_tokenId], "Token is not currently banned.");
        nftContract.transferFrom(address(this), msg.sender, _tokenId);
        bannedTokens[_tokenId] = false;
    }
}
