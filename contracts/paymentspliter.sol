// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract Split {
    address payable address1;
    address payable address2;
    uint256 balance;

    constructor(address payable _address1, address payable _address2)  {
        address1 = _address1;
        address2 = _address2;
        balance = address(this).balance;
    }

    function split() public {
        address1.transfer((balance * 40) / 100);
        address2.transfer((balance * 60) / 100);
    }
}
