// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/utils/math/SafeMath.sol";

contract Staking {
    using SafeMath for uint256;

    // Struct to store staker's data
    struct StakerData {
        uint256 totalStaked; // Total tokens staked by the user
        uint256 lastStakedTimestamp; // Timestamp when the user last staked
        uint256 reward; // Accumulated reward for the user
    }

    IERC20 public token; // Token being staked
    uint256 public rewardRate; // Reward rate in percentage

    mapping(address => StakerData) public stakers; // Mapping to store staker data

    event Staked(address indexed staker, uint256 amount);
    event Unstaked(address indexed unstaker, uint256 amount);
    event RewardClaimed(address indexed staker, uint256 reward);

    constructor(IERC20 _token, uint256 _rewardRate) {
        token = _token;
        rewardRate = _rewardRate;
    }

    /**
     * @dev Calculates the pending reward for a staker.
     * @param staker The address of the staker.
     * @return The pending reward amount.
     */
    function calculateReward(address staker) public view returns (uint256) {
        StakerData storage stakerData = stakers[staker];
        uint256 stakingDuration = block.timestamp.sub(stakerData.lastStakedTimestamp);
        return stakerData.totalStaked.mul(rewardRate).mul(stakingDuration).div(100);
    }

    /**
     * @dev Allows a user to stake tokens.
     * @param amount The amount of tokens to stake.
     */
    function stake(uint256 amount) public {
        require(amount > 0, "Amount must be greater than 0");
        token.transferFrom(msg.sender, address(this), amount);

        StakerData storage stakerData = stakers[msg.sender];
        stakerData.reward = stakerData.reward.add(calculateReward(msg.sender)); // Add pending reward
        stakerData.totalStaked = stakerData.totalStaked.add(amount); // Increase total staked amount
        stakerData.lastStakedTimestamp = block.timestamp; // Update last staked timestamp

        emit Staked(msg.sender, amount);
    }

    /**
     * @dev Allows a user to unstake tokens.
     * @param amount The amount of tokens to unstake.
     */
    function unstake(uint256 amount) public {
        StakerData storage stakerData = stakers[msg.sender];
        require(stakerData.totalStaked >= amount, "Not enough staked tokens");

        stakerData.reward = stakerData.reward.add(calculateReward(msg.sender)); // Add pending reward
        stakerData.totalStaked = stakerData.totalStaked.sub(amount); // Decrease total staked amount
        stakerData.lastStakedTimestamp = block.timestamp; // Update last staked timestamp

        token.transfer(msg.sender, amount); // Transfer unstaked tokens back to the user

        emit Unstaked(msg.sender, amount);
    }

    /**
     * @dev Allows a user to claim their accumulated reward.
     */
    function claimReward() public {
        StakerData storage stakerData = stakers[msg.sender];
        uint256 reward = stakerData.reward.add(calculateReward(msg.sender)); // Calculate total reward
        require(reward > 0, "No reward to claim");

        stakerData.reward = 0; // Reset the accumulated reward
        stakerData.lastStakedTimestamp = block.timestamp; // Update last staked timestamp

        token.transfer(msg.sender, reward); // Transfer the claimed reward to the user

        emit RewardClaimed(msg.sender, reward);
    }
}
// 0xE3A7b0AFC74614487F568442Ee9401662A62A835