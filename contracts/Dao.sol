// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;
import "@openzeppelin/contracts/utils/Counters.sol";

contract NFT {
    function isNFTHolder() public view returns (address) {
        return msg.sender;
    }
}

contract dao {
    using Counters for Counters.Counter;

    //total applications in dao
    Counters.Counter private _applicationsCounter;
    //state varaible
    // address public founder1;
    // address public founder2;
    // address public founder3;
    // address public founder4;
    //or creatting an array of founders
    address[] public founders;
    //nft contract
    NFT public nft;
    //struct
    struct application {
        address payable applicant;
        uint256 id;
        uint256 amountRequired;
        uint256 votesUp;
        uint256 votesDown;
        uint256 totalVote;
        uint256 deadline;
        bool passed;
        bool exit;
        // bool counConducted;
        mapping(address => bool) voteStatus;
    }
    //mapping
    mapping(uint256 => application) public Applications; //id to application

    //modifier
    modifier checkApplicantEligibility() {
        require(msg.sender == nft.isNFTHolder(), "Need to be an NFT holder");
        _;
    }

    //constructor
    constructor(address _nft, address[] memory _founder) {
        nft = NFT(_nft);
        founders = _founder;
        _applicationsCounter.increment();
    }

    //events
    event ApplicationsCreated(
        address indexed applicantAddress,
        uint256 id,
        uint256 amountRequired
    );

    //nft holder function
    function submitApplication(uint256 _amountRequired, uint256 _deadline)
        public
        checkApplicantEligibility
    {
        application storage newApplication = Applications[_applicationsCounter.current()];
        newApplication.id = _applicationsCounter.current();
        newApplication.exit = true;
        newApplication.deadline = block.number + _deadline;
        newApplication.amountRequired = _amountRequired;

        emit ApplicationsCreated(
            msg.sender,
            _applicationsCounter.current(),
            _amountRequired
        );
        _applicationsCounter.increment();
    }
}
