// SPDX-License-Identifier: UNLICENSED

/* 定義版本，這邊使用0.8.0 */
pragma solidity ^0.8.0;

/* 引入合約需要的檔案 */
import "./IERC20.sol";
import "./IERC20Metadata.sol";
import "./Ownable.sol";

/* 主合約定義，需要繼承相關檔案們 */
contract Erc20Bank is IERC20, IERC20Metadata, Ownable {
    mapping (address => uint256) private balance;

    mapping (address => mapping (address => uint256)) private _allowances;


    uint256 private _totalSupply;

    string private _name;
    string private _symbol;
    uint8 private _decimal;


    constructor(string memory name_, string memory symbol_) {
        _name = name_;
        _symbol = symbol_;
        _decimal = 18;
        _totalSupply = 0;
    }

    function name() external view virtual override returns (string memory) {
        return _name;
    }

    function symbol() external view virtual override returns (string memory) {
        return _symbol;
    }

    function decimals() external view virtual override returns (uint8) {
        return _decimal;
    }

    function totalSupply() external view virtual override returns (uint256) {
        return _totalSupply;
    }

    function balanceOf(address account) external view virtual override returns (uint256) {
        return balance[account];
    }

    error InsufficientCoin(uint256 requested, uint256 available);

    function transfer(address to, uint256 coinValue) public virtual override returns (bool) {
        require(to != address(0), "transfer to the zero address");

        if (coinValue > balance[msg.sender]){
            revert InsufficientCoin ({
                requested: coinValue,
                available: balance[msg.sender]
            });
        }

        balance[msg.sender] -= coinValue;
        balance[to] += coinValue;

        emit Transfer(msg.sender, to, coinValue);
        return true;
    }

    function mint(address receiver, uint amount) public onlyOwner {
        require(amount <= 7414, "No more than 7414 coins per mint");
        balance[receiver] += amount;

        _totalSupply += amount;
    }

    function approve(address spender, uint256 coinValue) external virtual override returns (bool) {
        require(spender != address(0), "approve to the zero address");

        address owner = msg.sender;
        _allowances[owner][spender] = coinValue;
        /* 觸發IERC20裡面說明的Approval事件 */
        emit Approval(owner, spender, coinValue);
        /* IERC20 裡面需要回傳一個布林 */
        return true;
    }

    function allowance(address owner, address spender) external view virtual override returns (uint256) {
        return _allowances[owner][spender];
    }

    function transferFrom(address sender, address to, uint256 coinValue) external override returns (bool) {
        require(sender != address(0), "transfer to the zero address");
        require(to != address(0), "transfer to the zero address");
        
        uint256 currentAllowance = _allowances[sender][msg.sender];
        require(currentAllowance >= coinValue, "transfer coinValue exceeds allowance");


        require(balance[sender] >= coinValue, "sender's balances are not enough");

        _allowances[sender][msg.sender] -= coinValue;

        balance[sender] -= coinValue;
        balance[to] += coinValue;

        /* 配合IERC20，只能觸發Transfer事件 */
        // emit TransferEvent(msg.sender, to, coinValue, now);
        emit Transfer(sender, to, coinValue);
        /* IERC20 裡面需要回傳一個布林 */
        return true;
    }
}