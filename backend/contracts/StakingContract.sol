//SPDX-License-Identifier: Unlicense
//specific solidity cersion
pragma solidity ^0.8.7;
import "hardhat/console.sol";

import "@openzeppelin/contracts/security/ReentrancyGuard.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

//user can deposit
//user can withdrawl
//user gets staking arwards

/// @title a staking contract
/// @author Johannes Müller
/// @notice This is just for learning purposes, dont use it on mainnet
/// @dev All functions are tested with associated unit test

contract Staking {
    error TransferFailed();
    error NeedsMoreThanZero();

    modifier moreThanZero(uint256 amount) {
        if (amount == 0) {
            revert NeedsMoreThanZero();
        }
        _;
    }

    event Deposit(
        address indexed account,
        address indexed token,
        uint256 indexed amount
    );

    /*STATE VARIABLES */

    IERC20 public s_stakingToken;
    uint256 public s_totalSupply;
    /// @dev key is users public address, value is the amount of ether
    mapping(address => uint256) public s_balances;

    /*------------ */

    /// @notice allowing only ERC20 compatible tokens to be staked
    /// @param stakingToken is the address of the smart contract that handles erc20 tokens
    /// @dev s_ is to bring awarness for storage variables
    constructor(address stakingToken) {
        s_stakingToken = IERC20(stakingToken);
    }

    /// @dev revert with revert all changes in a transaction, if transfer failed (balances and totalSupplay)
    /// @param amount: the amount of ether that the user wants to deposit
    function deposit(uint256 amount) public payable {
        s_balances[msg.sender] += amount;
        s_totalSupply += amount;
        bool success = s_stakingToken.transferFrom(
            msg.sender,
            address(this),
            amount
        );
        if (!success) revert TransferFailed();
    }

    /// @dev are stored in mapping balances
    /// @param amount: the amount of ether that the user wants to withdrawl
    function withdrawl(uint256 amount) public {
        s_balances[msg.sender] -= amount;
        s_totalSupply -= amount;
        bool success = s_stakingToken.transfer(
            msg.sender,
            amount
        );
        if (!success) revert TransferFailed();
    }
}
