// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.28;

import {ERC721URIStorage, ERC721} from "@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

struct NFTListing {
    uint256 price;
    address seller;
}

contract NFTMarket is ERC721URIStorage, Ownable {
    uint256 private _ids = 0;

    // Event ketika NFT dibuat, dijual, dan dibeli
    event NFTMinted(uint256 indexed tokenId, address owner, string tokenURI);
    event NFTListed(uint256 indexed tokenId, address seller, uint256 price);
    event NFTSold(uint256 indexed tokenId, address buyer, uint256 price);

    mapping(uint256 => NFTListing) private _listings;

    constructor(address initialOwner) ERC721("Sleep NFT", "SLP") Ownable(initialOwner) {}

    // ✅ Mint NFT baru
    function createNFT(string calldata tokenURI) public onlyOwner returns (uint256) {
        _ids++;
        _safeMint(msg.sender, _ids);
        _setTokenURI(_ids, tokenURI);

        emit NFTMinted(_ids, msg.sender, tokenURI);

        return _ids;
    }

    // ✅ List NFT di marketplace
    function listNFT(uint256 tokenId, uint256 price) public {
        require(ownerOf(tokenId) == msg.sender, "You are not the owner");
        require(price > 0, "Price must be greater than 0");

        _listings[tokenId] = NFTListing({price: price, seller: msg.sender});
        emit NFTListed(tokenId, msg.sender, price);
    }

    // ✅ Beli NFT yang terdaftar di marketplace
    function buyNFT(uint256 tokenId) public payable {
        NFTListing memory listing = _listings[tokenId];
        require(listing.price > 0, "NFT is not listed for sale");
        require(msg.value >= listing.price, "Insufficient funds");
        require(listing.seller != msg.sender, "You cannot buy your own NFT");

        // Transfer NFT ke pembeli
        _transfer(listing.seller, msg.sender, tokenId);
        
        // Bayar penjual (95% dari harga)
        payable(listing.seller).transfer(listing.price);

        // Kembalikan kelebihan dana ke pembeli
        if (msg.value > listing.price) {
            payable(msg.sender).transfer(msg.value - listing.price);
        }

        // Hapus listing NFT
        delete _listings[tokenId];

        emit NFTSold(tokenId, msg.sender, listing.price);
    }

    // ✅ Batalkan listing NFT
    function cancelListing(uint256 tokenId) public {
        NFTListing memory listing = _listings[tokenId];
        require(listing.price > 0, "NFT is not listed for sale");
        require(listing.seller == msg.sender, "You are not the seller");

        delete _listings[tokenId];

        require(ownerOf(tokenId) == msg.sender, "Ownership has changed unexpectedly");
    }

    // Fungsi untuk mengirim ETH ke user
    function rewardUser(address payable _user, uint256 _amount) external onlyOwner {
        require(address(this).balance >= _amount, "Not enough ETH in contract");

        (bool success, ) = _user.call{value: _amount}("");
        require(success, "ETH transfer failed");
    }

    // ✅ Tarik dana dari kontrak
    function withdrawFunds() public onlyOwner {
        uint256 balance = address(this).balance;
        require(balance > 0, "No funds to withdraw");

        payable(owner()).transfer(balance);
    }

    // ✅ Cek apakah NFT terdaftar
    function getListing(uint256 tokenId) public view returns (uint256 price, address seller) {
        NFTListing memory listing = _listings[tokenId];
        return (listing.price, listing.seller);
    }

    function getListings() public view returns (NFTListing[] memory) {
    NFTListing[] memory listings = new NFTListing[](_ids);
    for (uint256 i = 1; i <= _ids; i++) {
        if (_listings[i].price > 0) {
            listings[i - 1] = _listings[i];
        }
    }
    return listings;
}
}
