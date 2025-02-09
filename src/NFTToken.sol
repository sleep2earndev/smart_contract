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
        require(msg.value >= prices[tokenId] * amount, "Insufficient ETH");
        _mint(msg.sender, tokenId, amount, "");
    }

}