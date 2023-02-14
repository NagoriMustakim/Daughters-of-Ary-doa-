// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";
import "@openzeppelin/contracts/security/Pausable.sol";
import "@openzeppelin/contracts/token/ERC721/IERC721.sol";

contract aryaDao is Ownable, Pausable, ReentrancyGuard {
    //total applications in dao
    //nft contract interface
    IERC721 nft;
    //address of 4 founder of dao contract
    address public founder1;
    address public founder2;
    address public founder3;
    address public founder4;
    //mapping
    mapping(address => uint256) public maxPerweek;
    mapping(uint256 => application) public Applications;
    //struct
    struct application {
        address payable applicant;
        uint256 id;
        uint256 amountRequired;
        uint256 votesUp;
        uint256 votesDown;
        uint256 vetoUp;
        uint256 vetoDown;
        uint256 deadline;
        bool totalVote;
        bool vetoVote;
        bool passed;
        bool exists;
        Status status;
        // bool counConducted;
        mapping(address => bool) voteStatus;
    }
    enum Status {
        Pending,
        Approved,
        Rejected,
        Expired,
        funding,
        funded
    }

    constructor(
        address payable _nft,
        address _founter1,
        address _founter2,
        address _founter3,
        address _founter4
    ) {
        nft = IERC721(_nft);
        founder1 = _founter1;
        founder2 = _founter2;
        founder3 = _founter3;
        founder4 = _founter4;
    }

    //modifier
    modifier checkApplicantEligibility(uint256 _tokenid) {
        require(
            msg.sender == nft.ownerOf(_tokenid),
            "You are not owner of provided tokenid, yet you can't Vote on application!"
        );
        require(
            maxPerweek[msg.sender] < 1 minutes,
            "maximum one application can submit in week"
        );
        _;
    }

    //token id would be your nft token id
    function submitApplication(uint256 _tokenid, uint256 _amountRequired)
        public
        payable
        checkApplicantEligibility(_tokenid)
        whenNotPaused
    {
       
    }
}
