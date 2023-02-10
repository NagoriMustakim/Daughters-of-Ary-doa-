// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

error DEADLINE_HAS_PASSED();
error ENTER_MINIMUM_CONTRIBUTION();
error YOU_ARE_NOT_ELIGIBLE_FOR_REFUND();
error YOU_ARE_NOT_MANAGER();
error YOU_ARE_NOT_CONTRIBUTOR();

error YOU_HAVE_ALREADY_VOTED();
error YOU_ARE_NOT_ELIGIBLE_FOR_VOTE();
error THE_REQUEST_HAS_BEEN_COMPLETED();
error MAJORITY_DOES_NOT_SUPPORT();

contract CrowdFunding {
    mapping(address => uint256) public contributors;
    address public manager;
    uint256 public target;
    uint256 public minimumContribution;
    uint256 public raisedAmount;
    uint256 public noOfContributors;
    uint256 public deadline;

    struct Request {
        string description;
        address payable recipient;
        uint256 value;
        bool completed;
        uint256 noOfVoters;
        mapping(address => bool) voters;
    }   
    mapping(uint256 => Request) public requests;
    uint256 public numRequest;

    constructor(uint256 _target, uint256 _deadline) {
        target = _target;
        deadline = block.timestamp + _deadline;
        manager = msg.sender;
        minimumContribution = 100 wei;
    }

    function sendEth() public payable {
        if (block.timestamp > deadline) {
            revert DEADLINE_HAS_PASSED();
        }
        if (msg.value <= minimumContribution) {
            revert ENTER_MINIMUM_CONTRIBUTION();
        }
        if (contributors[msg.sender] == 0) {
            noOfContributors++;
        }
        contributors[msg.sender] += msg.value;
        raisedAmount += msg.value;
    }

    function getContractBalance() public view returns (uint256) {
        return address(this).balance;
    }

    function refund() public {
        if (block.timestamp < deadline && raisedAmount < target) {
            revert YOU_ARE_NOT_ELIGIBLE_FOR_REFUND();
        }
        if (contributors[msg.sender] < 0) {
            revert();
        }
        address payable user = payable(msg.sender);
        user.transfer(contributors[msg.sender]);
        contributors[msg.sender] = 0;
    }

    function createRequest(
        string memory _description,
        address payable _recipient,
        uint256 _value
    ) public {
        if (msg.sender != manager) {
            revert YOU_ARE_NOT_MANAGER();
        }
        Request storage newRequest = requests[numRequest];
        numRequest++;
        newRequest.description = _description;
        newRequest.recipient = _recipient;
        newRequest.value = _value;
        newRequest.completed = false;
        newRequest.noOfVoters = 0;
    }

    function voteRequest(uint256 _requestNo) public {
        if (block.timestamp < deadline && raisedAmount < target) {
            revert YOU_ARE_NOT_ELIGIBLE_FOR_VOTE();
        }
        if (contributors[msg.sender] < 0) {
            revert YOU_ARE_NOT_CONTRIBUTOR();
        }
        Request storage thisRequest = requests[_requestNo];
        if (thisRequest.voters[msg.sender] != false) {
            revert YOU_HAVE_ALREADY_VOTED();
        }
        thisRequest.voters[msg.sender] = true;
        thisRequest.noOfVoters++;
    }

    function makePayment(uint256 _requestNo) public {
        if (msg.sender != manager) {
            revert YOU_ARE_NOT_MANAGER();
        }
        if (raisedAmount <= target) {
            revert();
        }
        Request storage thisRequest = requests[_requestNo];
        if (thisRequest.completed != false) {
            revert THE_REQUEST_HAS_BEEN_COMPLETED();
        }
        if (thisRequest.noOfVoters < noOfContributors / 2) {
            revert MAJORITY_DOES_NOT_SUPPORT();
        }
        thisRequest.recipient.transfer(thisRequest.value);
        thisRequest.completed = true;
    }
}
