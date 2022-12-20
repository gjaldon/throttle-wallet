// SPDX-License-Identifier: ISC
pragma solidity 0.8.17;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";

// Uncomment this line to use console.log
// import "hardhat/console.sol";

contract ThrottleWallet {
    event Deposited(address indexed sender, address indexed account, uint256 amount);
    event Spent(address indexed account, address indexed recipient, uint256 amount);

    IERC20 immutable public token;
    uint256 immutable public maxLimit;
    uint256 immutable public refillRate;

    mapping(address => uint256) public balances;
    mapping(address => uint256) public spendingLimit;
    mapping(address => bool) public spent;

    constructor(address _token, uint256 _maxLimit, uint256 _refillRate) {
        require(_token != address(0), "token can not be zero address");
        require(_maxLimit > 0, "max limit must be greater than zero");
        require(_refillRate > 0, "refill rate must be greater than zero");

        token = IERC20(_token);
        maxLimit = _maxLimit;
        refillRate = _refillRate;
    }

    function deposit(address account, uint256 amount) external {
        require(token.balanceOf(msg.sender) >= amount, "lacking balance");
        require(token.allowance(msg.sender, address(this)) >= amount, "lacking allowance");

        balances[account] += amount;
        SafeERC20.safeTransfer(token, address(this), amount);

        emit Deposited({
            sender: msg.sender,
            account: account,
            amount: amount
        });
    }

    function spend(address recipient, uint256 amount) external {
        require(balances[msg.sender] >= amount, "lacking balance");
        bool _spent = spent[msg.sender];
        require(getLimit(msg.sender, _spent) >= amount, "lacking limit");

        if (_spent) {
            spendingLimit[msg.sender] -= amount;
        } else {
            spendingLimit[msg.sender] = maxLimit - amount;
        }

        balances[msg.sender] -= amount;
        SafeERC20.safeTransferFrom(token, address(this), recipient, amount);

        emit Spent({
            account: msg.sender,
            recipient: recipient,
            amount: amount
        });
    }

    function getLimit(address account, bool _spent) internal view returns (uint256) {
        if (_spent) {
            return spendingLimit[account];
        }
        return maxLimit;
    }
}
