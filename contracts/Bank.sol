// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.0;

contract Bank {
    address payable private owner;

    mapping (address => uint256) private balance;

    mapping (address => uint256) private coinBalance;

    event DepositEvent(address indexed from, uint256 value, uint256 timestamp);
    event WithdrawEvent(address indexed from, uint256 value, uint256 timestamp);
    event TransferEvent(address indexed from, address indexed to, uint256 value, uint256 timestamp);

    event MintEvent(address indexed from, uint256 value, uint256 timestamp);
    event BuyCoinEvent(address indexed from, uint256 value, uint256 timestamp);
    event TransferCoinEvent(address indexed from, address indexed to, uint256 value, uint256 timestamp);
    event TransferOwnerEvent(address indexed oldOwner, address indexed newOwner, uint256 timestamp);

    modifier isOwner() {
        require(owner == msg.sender, "you are not owner");
        _;
    }

	// 建構子
    constructor() payable {
        owner = payable(msg.sender);
    }

	// 存錢
    function deposit() public payable {
        balance[msg.sender] += msg.value;

        // emit DepositEvent
        emit DepositEvent(msg.sender, msg.value, block.timestamp);
    }

	// 提錢
    function withdraw(uint256 etherValue) external payable {
        uint256 weiValue = etherValue * 1 ether;
        address payable _sender = payable(msg.sender);
        require(balance[_sender] >= weiValue, "your balances are not enough");

        balance[_sender] -= weiValue;

        _sender.transfer(weiValue);

        emit WithdrawEvent(_sender, etherValue, block.timestamp);
    }

	// 轉帳
    function transfer(address to, uint256 etherValue) public {
        uint256 weiValue = etherValue * 1 ether;

        require(balance[msg.sender] >= weiValue, "your balances are not enough");

        balance[msg.sender] -= weiValue;
        balance[to] += weiValue;

        emit TransferEvent(msg.sender, to, etherValue, block.timestamp);
    }

	// mint coin
    function mint(uint256 coinValue) public isOwner {
        
        uint256 value = coinValue * 1 ether;

        require(value / coinValue == 1 ether, "safe math issue.");
        require(coinBalance[msg.sender] + value >= coinBalance[msg.sender], "safe math issue.");
        coinBalance[msg.sender] += value;
        emit MintEvent(msg.sender, coinValue, block.timestamp);
    }

	// 使用 bank 中的 ether 向 owner 購買 coin
    function buy(uint256 coinValue) public {
        uint256 value = coinValue * 1 ether;

        require(coinBalance[owner] >= value);
        require(balance[msg.sender] >= value);

        require(balance[msg.sender] - value <= balance[msg.sender], "safe math issue.");        
        balance[msg.sender] -= value;

        require(balance[owner] + value >= balance[owner], "safe math issue.");        
        balance[owner] += value;

        require(coinBalance[msg.sender] + value >= coinBalance[msg.sender], "safe math issue.");  
        coinBalance[msg.sender] += value;

        require(coinBalance[owner] - value <= coinBalance[owner], "safe math issue.");  
        coinBalance[owner] -= value;

        emit BuyCoinEvent(msg.sender, coinValue, block.timestamp);
    }

	// 轉移 coin
    function transferCoin(address to, uint256 coinValue) public {
        uint256 value = coinValue * 1 ether;

        require(coinBalance[msg.sender] >= value);
        require(coinBalance[msg.sender] - value <= coinBalance[msg.sender], "safe math issue.");  
        coinBalance[msg.sender] -= value;
        require(coinBalance[to] + value >= coinBalance[to], "safe math issue.");  
        coinBalance[to] += value;
        emit TransferCoinEvent(msg.sender, to, coinValue, block.timestamp);
    }

	// 檢查銀行帳戶餘額
    function getBankBalance() public view returns (uint256) {
        return balance[msg.sender];
    }

    // 檢查coin餘額
    function getCoinBalance() public view returns (uint256) {
        return coinBalance[msg.sender];
    }

    // get owner
    function getOwner() public view returns (address)  {
        return owner;
    }

    // 轉移owner
    function transferOwner(address payable newOwner) public isOwner {

        owner = newOwner;
        emit TransferOwnerEvent(msg.sender, newOwner, block.timestamp);
    }

    function kill() public isOwner {
        selfdestruct(owner);
    }
}