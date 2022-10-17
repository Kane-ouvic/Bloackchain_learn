// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.0;

contract Bank2{
    address private owner;

    mapping(address => uint256) public coins;

    event TransferCoinEvent(address indexed from, address indexed to, uint256 value);

    modifier isOwner() {
        require(owner == msg.sender, "you are not owner");
        _;
    }

    constructor() {
        owner = msg.sender;
    }

    //鑄造錢幣
    function mint(address receiver, uint amount) public isOwner {
        require(amount <= 7414, "No more than 7414 coins per mint");
        coins[receiver] += amount;
    }

    error InsufficientCoins(uint requested, uint available);

    // 當前使用者轉移錢幣
    function transferCoin(address to, uint coinValue) public {
        if (coinValue > coins[msg.sender]){
            revert InsufficientCoins({
                requested: coinValue,
                available: coins[msg.sender]
            });
        }

        coins[msg.sender] -= coinValue;
        coins[to] += coinValue;
        emit TransferCoinEvent(msg.sender, to, coinValue);
    }
}



