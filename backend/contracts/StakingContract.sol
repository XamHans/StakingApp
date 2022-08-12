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

    event DepositEvent(
        address indexed account,
        address indexed token,
        uint256 indexed amount
    );

    event WithdrawlEvent(
        address indexed account,
        address indexed token,
        uint256 indexed amount
    );

    /*STATE VARIABLES */

    IERC20 public s_stakingToken;
    IERC20 public s_rewardToken;

    uint256 public s_totalSupply;
    uint256 public s_rewardPerTokenStored;
    uint256 public s_lastUpdateTime;
    uint256 public constant REWARD_RATE = 100;

    mapping(address => uint256) public s_balances;
    // how much each address has been paid
    mapping(address => uint256) public s_userRewardPerTokenPaid;
    // how much awards each address has to claim
    mapping(address => uint256) public s_rewards;

    /*------------ */

    /********************/
    /* Modifiers Functions */
    /********************/
    modifier moreThanZero(uint256 amount) {
        if (amount == 0) {
            revert NeedsMoreThanZero();
        }
        _;
    }

    modifier updateReward(address account) {
        s_rewardPerTokenStored = rewardPerToken();
        s_lastUpdateTime = block.timestamp;
        s_rewards[account] = earned(account);
        s_userRewardPerTokenPaid[account] = s_rewardPerTokenStored;
        _;
    }

    function earned(address account) public view returns (uint256) {
        uint256 currentBalance = s_balances[account]; // current balance they user have staked
        // how much have user have peen paid already
        uint256 amountPaid = s_userRewardPerTokenPaid[account];
        uint256 currentRewardPerToken = rewardPerToken();
        uint256 pastRewards = s_rewards[account];

        uint256 earned = ((currentBalance *
            (currentRewardPerToken - amountPaid)) / 1e18) + pastRewards;
        return earned;
    }

    /// Based on how long its been during this most recent snapshopt
    function rewardPerToken() public view returns (uint256) {
        if (s_totalSupply == 0) {
            return s_rewardPerTokenStored;
        }
        /// how long (how many seconds has it been) is the reward time --> (block.timestamp - s_lastUpdateTime)
        /// * REWARD_RATE is 100 reward-tokens per second
        /// *1e18 ---> transform it to wei
        /// /s_totalSupply --> divided by current summed up staking tokens
        /// + s_rewardPerTokenStored ---> whatever the user have earned before

        return
            s_rewardPerTokenStored +
            (((block.timestamp - s_lastUpdateTime) * REWARD_RATE * 1e18) /
                s_totalSupply);
    }

    /// @notice allowing only ERC20 compatible tokens to be staked
    /// @param stakingToken is the address of the smart contract that handles erc20 tokens
    /// @dev s_ is to bring awarness for storage variables
    constructor(address stakingToken, address rewardToken) {
        s_stakingToken = IERC20(stakingToken);
        s_rewardToken = IERC20(rewardToken);
    }

    /// @dev revert with revert all changes in a transaction, if transfer failed (balances and totalSupplay)
    /// @param amount: the amount of ether that the user wants to deposit
    function stake(uint256 amount)
        public
        moreThanZero(amount)
        ReentrancyGuard
        updateReward(msg.sender)
    {
        s_balances[msg.sender] += amount;
        s_totalSupply += amount;
        emit DepositEvent(msg.sender, address(s_stakingToken), amount);
        bool success = s_stakingToken.transferFrom(
            msg.sender,
            address(this),
            amount
        );
        if (!success) revert TransferFailed();
    }

    /**
     * @notice Withdraw tokens from this contract
     * @param amount | How much to withdraw
     */
    function withdrawl(uint256 amount)
        public
        moreThanZero(amount)
        updateReward(msg.sender)
    {
        s_balances[msg.sender] -= amount;
        s_totalSupply -= amount;
        emit WithdrawlEvent(msg.sender, address(s_stakingToken), amount);
        bool success = s_stakingToken.transfer(msg.sender, amount);
        if (!success) revert TransferFailed();
    }

    /**
     * @notice User claims their tokens
     */
    function claimReward() external updateReward(msg.sender)  {
        uint256 reward = s_rewards[msg.sender];
        bool success = s_rewardsToken.transfer(msg.sender, reward);
        if (!success) revert TransferFailed();
    }
}
