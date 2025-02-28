// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.28;

import "@openzeppelin/contracts/access/Ownable.sol";

contract RewardClaim is Ownable {
    error RewardClaim__NotEnoughBalance();
    error RewardClaim__InvalidProof();
    error RewardClaim__AlreadyClaimed();
    error RewardClaim__NotEligible();

    struct UserClaim {
        bool hasClaimed;
        uint256 lastClaimTime;
    }

    struct ProofData {
        bool isMerged;
        address user;
    }

    mapping(address => UserClaim) private s_claims;
    mapping(uint256 => ProofData) public claims;

    event RewardDeposited(
        address indexed sender, 
        uint256 amount
    );

    event RewardClaimed(
        address indexed user, 
        uint256 amount
    );

    constructor(address initialOwner) Ownable(initialOwner) {}

    // Fungsi untuk mengisi smart contract dengan ETH sebagai pool reward
    function depositETH() external payable onlyOwner {
        require(msg.value > 0, "Deposit must be greater than 0");
        emit RewardDeposited(msg.sender, msg.value);
    }

    // Fungsi untuk klaim reward dengan validasi proof dari backend (dummy parameter _proof)
    function claimReward(
        bool isMerged,
        uint256 amount
    ) external {
        require(isMerged, "Sleep data not valid");
        require(amount > 0, "Invalid amount");
        require(address(this).balance >= amount, "Not enough ETH in contract");

        Cek apakah user sudah klaim dalam periode tertentu (contoh: 24 jam cooldown)
        if (s_claims[msg.sender].hasClaimed && 
            block.timestamp - s_claims[msg.sender].lastClaimTime < 1 days) {
            revert RewardClaim__AlreadyClaimed();
        }

        // Update status klaim user
        s_claims[msg.sender] = UserClaim(true, block.timestamp);

        // Kirim ETH ke user sebagai reward
        (bool success, ) = payable(msg.sender).call{value: amount}("");
        require(success, "Transfer failed");

        emit RewardClaimed(msg.sender, amount);
    }

    // Fungsi untuk cek saldo kontrak
    function getContractBalance() external view returns (uint256) {
        return address(this).balance;
    }
}
