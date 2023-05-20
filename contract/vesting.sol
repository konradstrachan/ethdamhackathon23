// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

interface IERC20 {
    function transfer(address recipient, uint256 amount) external returns (bool);
    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);
}

contract Vesting {
    struct VestingSchedule {
        uint256 cliffTime;
        uint256 endTime;
        uint256 totalAmount;
        uint256 releasedAmount;
    }

    mapping(address => mapping(address => VestingSchedule[])) private tokenVestings;

    event FundsStaked(
        address indexed beneficiary,
        address indexed token,
        uint256 totalAmount,
        uint256 cliffTime,
        uint256 endTime
    );

    event FundsWithdrawn(
        address indexed beneficiary,
        address indexed token,
        uint256 scheduleIndex,
        uint256 amount
    );

    function stakeFunds(
        address beneficiary,
        address tokenAddress,
        uint256 cliffTime,
        uint256 endTime,
        uint256 totalAmount
    ) external {
        require(cliffTime >= block.timestamp, "Cliff time must be in the future");
        require(endTime > cliffTime, "End time must be after cliff time");
        require(totalAmount > 0, "Total amount must be greater than zero");

        require(
            IERC20(tokenAddress).transferFrom(msg.sender, address(this), totalAmount),
            "Token transfer failed"
        );

        VestingSchedule[] storage vestingSchedules = tokenVestings[beneficiary][tokenAddress];
        vestingSchedules.push(VestingSchedule(cliffTime, endTime, totalAmount, 0));

        emit FundsStaked(beneficiary, tokenAddress, totalAmount, cliffTime, endTime);
    }

    function withdrawFunds(address tokenAddress, uint256 scheduleIndex) external {
        VestingSchedule[] storage vestingSchedules = tokenVestings[msg.sender][tokenAddress];
        require(scheduleIndex < vestingSchedules.length, "Invalid schedule index");

        VestingSchedule storage vestingSchedule = vestingSchedules[scheduleIndex];
        require(vestingSchedule.cliffTime <= block.timestamp, "Funds are still in the cliff period");

        uint256 withdrawableAmount = calculateWithdrawableAmount(vestingSchedule);
        require(withdrawableAmount > 0, "No funds available for withdrawal");

        vestingSchedule.releasedAmount += withdrawableAmount;

        require(
            IERC20(tokenAddress).transfer(msg.sender, withdrawableAmount),
            "Token transfer failed"
        );

        emit FundsWithdrawn(msg.sender, tokenAddress, scheduleIndex, withdrawableAmount);

        if (vestingSchedule.releasedAmount == vestingSchedule.totalAmount) {
            delete vestingSchedules[scheduleIndex];
        }
    }

    function getStakesForBeneficiary(address beneficiary, address tokenAddress) external view returns (VestingSchedule[] memory) {
        return tokenVestings[beneficiary][tokenAddress];
    }

    function calculateWithdrawableAmount(VestingSchedule storage vestingSchedule) private view returns (uint256) {
        uint256 elapsedTime = block.timestamp - vestingSchedule.cliffTime;

        if (elapsedTime >= vestingSchedule.endTime - vestingSchedule.cliffTime) {
            // Can now access all of the funds minus any that have already been claimed
            return vestingSchedule.totalAmount - vestingSchedule.releasedAmount;
        } else {
            // Calculate what proportion of funds is now available and only return that amount

            // How long is the unlock period
            uint256 totalUnlockPeriod = vestingSchedule.endTime - vestingSchedule.cliffTime; 
            
            // How much should have been unlocked so far
            uint256 totalAmountAccessible = (vestingSchedule.totalAmount / totalUnlockPeriod) * elapsedTime;
            
            // Amount available to withdraw is the currently unlocked amount minus anything
            // that has already been claimed to prevent repeat counting funds
            uint256 actualAccessible = totalAmountAccessible - vestingSchedule.releasedAmount;

            return actualAccessible;
        }
    }

    function getBlockTime() external view returns (uint256) {
        return block.timestamp;
    }
}
