// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;
import {Ownable} from "@openzeppelin/contracts/access/Ownable.sol";
import {ReentrancyGuard} from "@openzeppelin/contracts/security/ReentrancyGuard.sol";
import {ERC721} from "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import {Counters} from "@openzeppelin/contracts/utils/Counters.sol";
import {Pausable} from "@openzeppelin/contracts/security/Pausable.sol";
import {Strings} from "@openzeppelin/contracts/utils/Strings.sol";

contract HeroNFT is ERC721, Ownable, ReentrancyGuard, Pausable {
    event TransferToFunder(address indexed founder, uint256 tokenid);
    address public founder;

    constructor(address _founder) ERC721("HeroNFT", "HNFT") {
        founder = _founder;
    }

    function mintHero() internal onlyOwner {
        for (uint256 i = 0; i < 25; i++) {
            _safeMint(msg.sender, i);
        }

    }
    function transferToFounders()public onlyOwner{
        for (uint256 i = 0; i < 25; i++) {
            
    }
}
