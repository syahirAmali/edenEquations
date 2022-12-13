// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.9;

// Uncomment this line to use console.log
// import "hardhat/console.sol";

// TODO make sure any percentage or decimals is converted to basis points

contract Equations {

    struct StakerValue {
        NoOfEndorcements NE;
        QualityOfStakes QS;
        uint256 stakeAmount;
    }

    /// @notice Gets the reward per user
    /// @param m multiplier = (how much extra from the stake ammount you want to give) - (approximately the upper limit of the MR as long as the Q of the stakers is high)
    /// @param MR a struct of the params to get the value of quality amount for each user
    /// @param weightage0 weightage of the number of endorcements
    /// @param weightage1 weightage of the quality of stakes
    /// @notice the weightage should be entered in basis points and equals to 10_000
    /// @param staker a struct of the params to get the value of the staker
    function rewardPerUser(uint256 m, MaxRewards[] memory MR, uint256 weightage0, uint256 weightage1, StakerValue memory staker) public pure returns (uint256 rewards_) { 
        
        uint256 maxReward = getMaxRewards(m, MR, weightage0, weightage1);
        
        uint256 valueOfStaker = valueOfQualityAmount(weightage0, weightage1, staker.NE, staker.QS, staker.stakeAmount);

        uint256 sumOfStakers = getSumOfStakers(MR, weightage0, weightage1);

        rewards_ = (valueOfStaker / sumOfStakers) * maxReward;
    }

    struct MaxRewards {
        NoOfEndorcements NE;
        QualityOfStakes QS;
        uint256 stakeAmount;
    }

    /// @notice gets the maximum reward for all of the stakers combined on a specific user
    /// @param m how much extra reward from the stake amount you want to give - approximately the upper limit of the maxRewards as long as the quality of the staker is high
    /// @notice the m should be entered in basis points and equals to 10_000
    /// @param MR a struct of the params to get the value of quality amount for each user
    /// @param weightage0 weightage of the number of endorcements
    /// @param weightage1 weightage of the quality of stakes
    /// @notice the weightage should be entered in basis points and equals to 10_000
    function getMaxRewards(uint256 m, MaxRewards[] memory MR, uint256 weightage0, uint256 weightage1) public pure returns (uint256 maxRewards_) {
        
        uint256 sumOfStakers = getSumOfStakers(MR, weightage0, weightage1);

        maxRewards_ = (sumOfStakers * m) / 10_000;
    }

    /// @notice Gets the sum of staker quality amount on a user
    /// @param MR struct used to get the values relevant to find the sum of stakers and max rewards
    /// @param weightage0 weightage of the number of endorcements
    /// @param weightage1 weightage of the quality of stakes
    /// @notice the weightage should be entered in basis points and equals to 10_000
    function getSumOfStakers(MaxRewards[] memory MR, uint256 weightage0, uint256 weightage1) public pure returns (uint256 sumOfStakers_) {
        require(MR.length != 0, "!length");

        uint256 L = MR.length;
        sumOfStakers_ = 0;

        for(uint256 i = 0; i < L; i++){
            sumOfStakers_ += valueOfQualityAmount(weightage0, weightage1, MR[i].NE, MR[i].QS, MR[i].stakeAmount);
        }
    }

    /// @notice get the sum of quality of a user
    /// @param weightage0 weightage of the number of endorcements
    /// @param weightage1 weightage of the quality of stakes
    /// @notice the weightage should be entered in basis points and equals to 10_000
    /// @param NE a struct of the params for getting the number of endorcements
    /// @param QS a struct of the params for getting the quality of stakes
    /// @param stakeAmount amount staked by the user on this specific user
    /// @return value_ returns quality of stake against the stakeAmount
    function valueOfQualityAmount(uint256 weightage0, uint256 weightage1, NoOfEndorcements memory NE, QualityOfStakes memory QS, uint256 stakeAmount) public pure returns (uint256 value_) {
        value_ = qualityOfStaker(weightage0, weightage1, NE, QS) * stakeAmount;
    }

    struct NoOfEndorcements {
        uint256 v;
        uint256 mE;
        uint256 eN;
    }

    struct QualityOfStakes {
        uint256[] cr;
        uint256[] cd;
    }

    /// @notice gets the quality of a staker
    /// @param weightage0 weightage of the number of endorcements
    /// @param weightage1 weightage of the quality of stakes
    /// @notice the weightage should be entered in basis points and equals to 10_000
    /// @param NE a struct of the params for getting the number of endorcements
    /// @param QS a struct of the params for getting the quality of stakes
    /// @return quality_ returns the quality of a staker
    function qualityOfStaker(uint256 weightage0, uint256 weightage1, NoOfEndorcements memory NE, QualityOfStakes memory QS) public pure returns (uint256 quality_){
        quality_ = ((weightage0 * numberOfEndorcements(NE.v, NE.mE, NE.eN))) / 10_100 + ((weightage1 * qualityOfStakes(QS.cr, QS.cd))) / 10_000;
    }
    
    /// @notice determine the quality of stake
    /// @param cr how much the user brings to a protocol
    /// @param cd how much staked on this user
    /// @notice the number of users that you staked
    /// @return quality_ the quality of stakes
    function qualityOfStakes(uint256[] memory cr, uint256[] memory cd) public pure returns (uint256 quality_) {
        require(cr.length == cd.length, "!length");
        uint256 N = cr.length;
        uint256 sum = 0;

        for(uint256 i = 0; i < N; i++){
            sum += cr[i] / cd[i];
        }

        quality_ = sum / N;
    }

    /// @notice calculate the number of endorcement points
    /// @param v penalty number for small number of endorcements
    /// @notice penalty should be entered as a basis point and be less than 10_000
    /// @param mE max number of endorcements
    /// @param eN number of endorcements
    function numberOfEndorcements(uint256 v, uint256 mE, uint256 eN) public pure returns (uint256 number_) {
        number_ = (((1 + v) / mE) * eN - v) / 10_000;
    }
}