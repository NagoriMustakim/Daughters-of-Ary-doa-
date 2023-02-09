// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract MyNFT {
    uint256[] public tokenIds;
    mapping(uint256 => address) public tokenOwners;

    function transfer(uint256[] memory _tokenIds, address[] memory _recipients)
        public
    {
        require(
            _tokenIds.length == 25,
            "Error: Incorrect number of tokens to transfer"
        );
        require(
            _recipients.length == 10,
            "Error: Incorrect number of recipients"
        );

        // Shuffle the recipients array to randomly distribute tokens
        for (uint256 i = 0; i < _recipients.length; i++) {
            uint256 randomIndex = uint256(
                uint256(keccak256(abi.encodePacked(block.timestamp, i))) %
                    _recipients.length
            );
            address temp = _recipients[i];
            _recipients[i] = _recipients[randomIndex];
            _recipients[randomIndex] = temp;
        }

        // Transfer tokens to recipients
        uint256 recipientIndex = 0;
        for (uint256 i = 0; i < _tokenIds.length; i++) {
            tokenOwners[_tokenIds[i]] = _recipients[recipientIndex];
            recipientIndex = (recipientIndex + 1) % 10;
        }
    }
}
