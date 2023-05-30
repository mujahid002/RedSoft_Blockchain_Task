// Staking contract deployed to: 0x359a2ecCb12239350a3508aFCF2adCE3DD56FbdB

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/utils/math/SafeMath.sol";

contract Staking {

    using SafeMath for uint256;

    IERC20 public token; // Token being staked
    uint256 public rewardRate; // Reward rate in percentage

    // Struct to store user's staking data
    struct StakerData {
        uint256 totalStaked; // Total tokens staked by the user
        uint256 lastStakedTimestamp; // Timestamp when the user last staked
        uint256 reward; // Accumulated reward for the user
    }

    mapping(address => StakerData) public stakers; // Mapping to store staker data

    constructor(IERC20 _token, uint256 _rewardRate) {
        token = _token;
        rewardRate = _rewardRate;
    }

    /**
     * @dev Calculates the pending reward for a staker.
     * @param user The address of the staker.
     * @return The pending reward amount.
     */
    function calculateReward(address user) public view returns (uint256) {
        StakerData storage staker = stakers[user];
        uint256 stakingDuration = block.timestamp.sub(staker.lastStakedTimestamp);
        return staker.totalStaked.mul(rewardRate).mul(stakingDuration).div(100);
    }

    /**
     * @dev Allows a user to stake tokens.
     * @param amount The amount of tokens to stake.
     */
    function stake(uint256 amount) public {
        require(amount > 0, "Amount must be greater than 0");
        token.transferFrom(msg.sender, address(this), amount);

        // Update staker's data
        StakerData storage staker = stakers[msg.sender];
        staker.reward = staker.reward.add(calculateReward(msg.sender)); // Add pending reward
        staker.totalStaked = staker.totalStaked.add(amount); // Increase total staked amount
        staker.lastStakedTimestamp = block.timestamp; // Update last staked timestamp
    }

    /**
     * @dev Allows a user to unstake tokens.
     * @param amount The amount of tokens to unstake.
     */
    function unstake(uint256 amount) public {
        StakerData storage staker = stakers[msg.sender];
        require(staker.totalStaked >= amount, "Not enough staked tokens");

        // Update staker's data
        staker.reward = staker.reward.add(calculateReward(msg.sender)); // Add pending reward
        staker.totalStaked = staker.totalStaked.sub(amount); // Decrease total staked amount
        staker.lastStakedTimestamp = block.timestamp; // Update last staked timestamp

        token.transfer(msg.sender, amount); // Transfer unstaked tokens back to the user
    }

    /**
     * @dev Allows a user to claim their accumulated reward.
     */
    function claimReward() public {
        StakerData storage staker = stakers[msg.sender];
        uint256 reward = staker.reward.add(calculateReward(msg.sender)); // Calculate total reward
        require(reward > 0, "No reward to claim");

        staker.reward = 0; // Reset the accumulated reward
        staker.lastStakedTimestamp = block.timestamp; // Update last staked timestamp

        token.transfer(msg.sender, reward); // Transfer the claimed reward to the user
    }
}
