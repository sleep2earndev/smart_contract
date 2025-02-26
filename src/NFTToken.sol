// SPDX-License-Identifier: MIT
// Compatible with OpenZeppelin Contracts ^5.0.0
pragma solidity ^0.8.22;

import "../lib/openzeppelin-contracts/contracts/access/Ownable.sol";
import "../lib/openzeppelin-contracts/contracts/token/ERC1155/ERC1155.sol";

contract TokenNFT is ERC1155, Ownable {
    mapping(uint256 => uint256) public prices;

    constructor() ERC1155("") Ownable(msg.sender) {
    }

    function setURI(string memory newuri) public onlyOwner {
        _setURI(newuri);
    }

    function mint(uint256 tokenId, uint256 ammount) public onlyOwner{
        _mint(msg.sender,tokenId,ammount, "");
    }

    function addToken(uint256 tokenId, uint256 price) public onlyOwner{
        prices[tokenId] = price;
    }

    function buyToken(uint256 tokenId, uint256 amount) public payable {
        require(prices[tokenId] > 0, "Token not for sale");
        uint256 totalCost = prices[tokenId] * amount;
        require(msg.value >= totalCost, "Insufficient ETH");

        // Jika user mengirim lebih banyak ETH dari harga token, kembalikan kelebihan ETH
        if (msg.value > totalCost) {
            payable(msg.sender).transfer(msg.value - totalCost);
        }

        _mint(msg.sender, tokenId, amount, "");
    }

    // Fungsi untuk mengirim ETH ke user
    function rewardUser(address payable _user, uint256 _amount) external onlyOwner {
        require(address(this).balance >= _amount, "Not enough ETH in contract");

        (bool success, ) = _user.call{value: _amount}("");
        require(success, "ETH transfer failed");
    }

    // Fungsi untuk menarik ETH dari kontrak
    function withdraw(uint256 _amount) external onlyOwner {
        require(address(this).balance >= _amount, "Not enough ETH");

        (bool success, ) = payable(owner()).call{value: _amount}("");
        require(success, "Withdraw failed");
    }

    // Fungsi untuk menerima ETH ke smart contract
    receive() external payable {}

}