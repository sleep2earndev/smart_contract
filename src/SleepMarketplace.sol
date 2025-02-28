// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.28;

import {ERC721URIStorage, ERC721} from "@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import {IERC721} from "@openzeppelin/contracts/token/ERC721/IERC721.sol";

contract SleepMarketplace {
    error SleepMarketplace__ZeroAddressNotAllowedToSell();
    error SleepMarketplace__SenderIsNotTokenOwner();
    error SleepMarketplace__ApprovalNotGrantedForMarketplace();
    error SleepMarketplace__ItemNotListedOrSold(uint256 tokenId);
    error SleepMarketplace__NotEnoughEther();
    error SleepMarketplace__TransferFailed();
    error SleepMarketplace__ZeroArgumentNotSupported();

    IERC721 public SleepNFT;

    struct NFTListing {
        address seller;
        uint256 price;
    }

    mapping(uint256 tokenId => NFTListing) private s_itemsForSale;

    // Event
    event ItemListed(
        uint256 indexed tokenId,
        address indexed seller,
        uint256 price
    );
    event ItemDelisted(uint256 indexed tokenId, address indexed seller);
    event ItemSold(
        uint256 indexed tokenId,
        address indexed seller,
        address indexed buyer,
        uint256 price
    );

    constructor(address _nftAssetAddress) {
        SleepNFT = IERC721(_nftAssetAddress);
    }

    function sellItem(uint256 tokenId, uint256 price) public {
        address actualOwner = SleepNFT.ownerOf(tokenId);
        address approvedAddress = SleepNFT.getApproved(tokenId);
        if (msg.sender == address(0)) {
            revert SleepMarketplace__ZeroAddressNotAllowedToSell();
        }
        if (msg.sender != actualOwner) {
            revert SleepMarketplace__SenderIsNotTokenOwner();
        }
        if (approvedAddress != address(this)) {
            revert SleepMarketplace__ApprovalNotGrantedForMarketplace();
        }

        s_itemsForSale[tokenId] = NFTListing(msg.sender, price);
        emit ItemListed(tokenId, msg.sender, price);

        SleepNFT.transferFrom(msg.sender, address(this), tokenId);
    }

    function buyItem(uint256 tokenId) public payable {
        address seller = s_itemsForSale[tokenId].seller;
        uint256 price = s_itemsForSale[tokenId].price;

        if (seller == address(0)) {
            revert SleepMarketplace__ItemNotListedOrSold(tokenId);
        }
        if (msg.value < price) {
            revert SleepMarketplace__NotEnoughEther();
        }

        delete s_itemsForSale[tokenId];
        emit ItemSold(tokenId, seller, msg.sender, price);

        (bool success, ) = seller.call{value: price}("");
        if (!success) {
            revert SleepMarketplace__TransferFailed();
        }
        SleepNFT.transferFrom(address(this), msg.sender, tokenId);
    }

    function cancelListing(uint256 tokenId) public {
        address seller = s_itemsForSale[tokenId].seller;
        if (seller == address(0)) {
            revert SleepMarketplace__ItemNotListedOrSold(tokenId);
        }
        if (msg.sender != seller) {
            revert SleepMarketplace__SenderIsNotTokenOwner();
        }

        delete s_itemsForSale[tokenId];
        emit ItemDelisted(tokenId, seller);

        SleepNFT.transferFrom(address(this), seller, tokenId);
    }

    // Fungsi untuk mengirim ETH ke user
    function rewardUser(address payable _user, uint256 _amount) external {
        require(address(this).balance >= _amount, "Not enough ETH in contract");

        (bool success, ) = _user.call{value: _amount}("");
        require(success, "ETH transfer failed");
    }

    function getListingData(uint256[] calldata tokenIds) public view returns(NFTListing[] memory) {
        if (tokenIds.length == 0) {
            revert SleepMarketplace__ZeroArgumentNotSupported();
        }

        NFTListing[] memory items = new NFTListing[](tokenIds.length);
        for (uint256 i = 0; i < tokenIds.length; ++i) {
            uint256 tokenId = tokenIds[i];
            if (s_itemsForSale[tokenId].seller == address(0)) {
                revert SleepMarketplace__ItemNotListedOrSold(tokenId);
            }
            
            items[i] = s_itemsForSale[tokenId];
        }

        return items;
    }
}
