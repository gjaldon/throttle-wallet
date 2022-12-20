// SPDX-License-Identifier: ISC
pragma solidity 0.8.17;

// Uncomment this line to use console.log
// import "hardhat/console.sol";

contract ThrottleWallet {
    address immutable public token;
    uint256 immutable public maxLimit;
    uint256 immutable public refillRate;

    constructor(address _token, uint256 _maxLimit, uint256 _refillRate) {
        require(_token != address(0), "token can not be zero address");
        require(_maxLimit > 0, "max limit must be greater than zero");
        require(_refillRate > 0, "refill rate must be greater than zero");

        token = _token;
        maxLimit = _maxLimit;
        refillRate = _refillRate;
    }
}
