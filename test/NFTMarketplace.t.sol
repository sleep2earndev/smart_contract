// SPDX-License-Identifier: MIT
pragma solidity ^0.8.28;

import "forge-std/Test.sol";
import "../src/NFTMarketplace.sol";

contract NFTMarketTest is Test {
    NFTMarket public nftMarket;
    address public owner = address(0x123);
    address public buyer = address(0x456);

    function setUp() public {
        // Deploy smart contract sebelum setiap test
        vm.prank(owner);
        nftMarket = new NFTMarket(owner);
    }

    // ✅ Test fungsi `createNFT`
    function testCreateNFT() public {
        vm.prank(owner);
        uint256 tokenId = nftMarket.createNFT("ipfs://token-uri");

        // Pastikan tokenId yang dihasilkan benar
        assertEq(tokenId, 1);

        // Pastikan NFT dimiliki oleh pemilik
        assertEq(nftMarket.ownerOf(tokenId), owner);
    }

    // ✅ Test fungsi `listNFT`
    function testListNFT() public {
        // Mint NFT terlebih dahulu
        vm.prank(owner);
        uint256 tokenId = nftMarket.createNFT("ipfs://token-uri");

        // Listing NFT
        vm.prank(owner);
        nftMarket.listNFT(tokenId, 1 ether);

        // Pastikan NFT terdaftar dengan harga yang benar
        (uint256 price, address seller) = nftMarket.getListing(tokenId);
        assertEq(price, 1 ether);
        assertEq(seller, owner);
    }

    // ✅ Test fungsi `buyNFT`
    function testBuyNFT() public {
        // Mint dan listing NFT
        vm.prank(owner);
        uint256 tokenId = nftMarket.createNFT("ipfs://token-uri");
        vm.prank(owner);
        nftMarket.listNFT(tokenId, 1 ether);

        // Beli NFT
        vm.deal(buyer, 2 ether); // Beri dana ke pembeli
        vm.prank(buyer);
        nftMarket.buyNFT{value: 1 ether}(tokenId);

        // Pastikan NFT sekarang dimiliki oleh pembeli
        assertEq(nftMarket.ownerOf(tokenId), buyer);

        // Pastikan penjual menerima dana
        assertEq(owner.balance, 1 ether); // 95% dari harga
    }

    // ✅ Test fungsi `cancelListing`
    function testCancelListing() public {
        // Mint dan listing NFT
        vm.prank(owner);
        uint256 tokenId = nftMarket.createNFT("ipfs://token-uri");
        vm.prank(owner);
        nftMarket.listNFT(tokenId, 1 ether);

        // Batalkan listing
        vm.prank(owner);
        nftMarket.cancelListing(tokenId);

        // Pastikan NFT tidak lagi terdaftar
        (uint256 price, address seller) = nftMarket.getListing(tokenId);
        assertEq(price, 0);
        assertEq(seller, address(0));
    }


}