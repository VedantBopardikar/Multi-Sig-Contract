//["0x5B38Da6a701c568545dCfcB03FcB875f56beddC4","0xAb8483F64d9C6d1EcF9b849Ae677dD3315835cb2","0x4B20993Bc481177ec7E8f571ceCaE8A9e22C02db"]

// SPDX-License-Identifier: MIT
pragma solidity >=0.7.0 <0.9.0;

contract MultiSigWallet {
    event Deposit(address indexed sender, uint256 amount, uint256 balance);
    event SubmitTransaction(
        address indexed owner,
        uint256 indexed txIndex,
        address indexed to,
        uint256 value,
        bytes data
    );
    event ConfirmTransaction(address indexed owner, uint256 indexed txIndex);
    event RevokeConfirmation(address indexed owner, uint256 indexed txIndex);
    event ExecuteTransaction(address indexed owner, uint256 indexed txIndex);

    address[] public signatoryWallets;
    mapping(address => bool) public isOwner;
    
    

    struct Transaction {
        address to;
        uint256 value;
        bytes data;
        bool executed;
        uint numConfirmations;
        uint256 percentageOfConfirmation;
    }

    // mapping from tx index => owner => bool
    mapping(uint256 => mapping(address => bool)) public isConfirmed;

    Transaction[] public transactions;

    modifier onlyOwner() {
        require(isOwner[msg.sender], "not owner");
        _;
    }

    modifier txExists(uint256 _txIndex) {
        require(_txIndex < transactions.length, "tx does not exist");
        _;
    }

    

    modifier notExecuted(uint256 _txIndex) {
        require(transactions[_txIndex].executed!=true, "tx already executed");
        _;
    }

    modifier notConfirmed(uint256 _txIndex) {
        require(!isConfirmed[_txIndex][msg.sender], "tx already confirmed");
        _;
    }

    modifier notEnoughApprovals(uint256 _txIndex){
        Transaction storage transaction = transactions[_txIndex];
       require(((signatoryWallets.length * 6000000000000000) > 6000000000000000) == true,"Not enough authorization from signatory wallets"); 
        _;
      
    }

    constructor(address[] memory _owners) {
        require(_owners.length > 0, "owners required");

        for (uint256 i = 0; i < _owners.length; i++) {
            address owner = _owners[i];
        //check invalid owner entries and duplicate entries.
            require(owner != address(0), "invalid owner");
            require(!isOwner[owner], "owner not unique");
        //confirm valid entries as owners and add them in address array "signatoryWallets"
            isOwner[owner] = true;
            signatoryWallets.push(owner);
        }

        
    }

    receive() external payable {
        emit Deposit(msg.sender, msg.value, address(this).balance);
    }

    function submitTransaction(
        address _to,
        uint256 _value,
        bytes memory _data
    ) public onlyOwner {
        uint256 txIndex = transactions.length;

        transactions.push(
            Transaction({
                to: _to,
                value: _value,
                data: _data,
                executed: false,
                numConfirmations:0,
                percentageOfConfirmation: 0
            })
        );

        emit SubmitTransaction(msg.sender, txIndex, _to, _value, _data);
    }

    

    function approveTransaction(uint256 _txIndex)
        public
        onlyOwner
        txExists(_txIndex)
        notExecuted(_txIndex)
        notConfirmed(_txIndex)
    {
        Transaction storage transaction = transactions[_txIndex];
        transaction.numConfirmations += 1;
        isConfirmed[_txIndex][msg.sender] = true;
        emit ConfirmTransaction(msg.sender, _txIndex);
    }

    function executeTransaction(uint256 _txIndex)
        public
        onlyOwner
        txExists(_txIndex)
        notExecuted(_txIndex)
        notEnoughApprovals(_txIndex)
    {
        Transaction storage transaction = transactions[_txIndex];
            transaction.executed = true;

            (bool success, ) = transaction.to.call{value: transaction.value}(transaction.data);
            require(success, "Transaction Unsuccessfull");

            emit ExecuteTransaction(msg.sender, _txIndex);
        
    }

    function revokeConfirmation(uint256 _txIndex)
        public
        onlyOwner
        txExists(_txIndex)
        notExecuted(_txIndex)
    {
        Transaction storage transaction = transactions[_txIndex];

        require(isConfirmed[_txIndex][msg.sender], "transaction not confirmed");

        transaction.numConfirmations -= 1;
        isConfirmed[_txIndex][msg.sender] = false;

        emit RevokeConfirmation(msg.sender, _txIndex);
    }

    function getOwners() public view returns (address[] memory) {
        return signatoryWallets;
    }

    function getTransactionCount() public view returns (uint256) {
        return transactions.length;
    }

    function getTransaction(uint256 _txIndex)
        public
        view
        returns (
            address to,
            uint256 value,
            bytes memory data,
            bool executed,
            uint256 percentageOfConfirmation
        )
    {
        Transaction storage transaction = transactions[_txIndex];

        return (
            transaction.to,
            transaction.value,
            transaction.data,
            transaction.executed,
           (signatoryWallets.length * 6000000000000000)
        );
    }

    function getConfirmed(uint256 _txIndex) public view returns (uint256) {
    Transaction storage transaction = transactions[_txIndex];
    return transaction.numConfirmations;
}
}

