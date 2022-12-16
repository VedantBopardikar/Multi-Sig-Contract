// SPDX-License-Identifier: MIT
pragma solidity >=0.7.0 <0.9.0;

contract AccessRegisty {
    address public admin;
    mapping(address => bool) signatories;

    constructor() {
        admin = msg.sender;
    }

    function addSignatory(address newSignatory) public {
        require(admin == msg.sender, "Only admin can add signatories");
        signatories[newSignatory] = true;
    }

    

    function revokeSignatory(address signatoryToRevoke) public {
        require(admin == msg.sender, "Only admin can revoke signatories");
        delete signatories[signatoryToRevoke];
    }

    function renounceSignatory(address signatoryToRenounce) public {
        require(admin == msg.sender, "Only admin can remove signatories");
        delete signatories[signatoryToRenounce];
    }

    

    function transferSignatory(address fromSignatory, address toSignatory)
        public
    {
        require(admin == msg.sender, "Only admin can transfer signatories");
        signatories[toSignatory] = true;
        delete signatories[fromSignatory];
    }

    function getSignatories()public view returns(address[] memory){
        
    }

}
