// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {Test, console} from "forge-std/Test.sol";
import {TokenNFT} from "../src/NFTToken.sol";
import "../lib/openzeppelin-contracts/contracts/access/Ownable.sol";


contract TokenNftTest is Test {
    TokenNFT public tokenNFT;
    address public owner = makeAddr("owner");
    address public user = makeAddr("user");

    function setUp() public {
        vm.prank(owner);
        tokenNFT = new TokenNFT();
    }

    function test_Mint() public {
        vm.startPrank(owner);
        console.log(owner);
        tokenNFT.mint(1,10);
        tokenNFT.mint(2,20);
        assertEq(tokenNFT.balanceOf(address(owner),1),10);
        assertEq(tokenNFT.balanceOf(address(owner),2),20);
    }

    function test_AddToken() public {
        vm.startPrank(owner);
        tokenNFT.addToken(1,0.01 ether);
        tokenNFT.addToken(2,0.02 ether);
        assertEq(tokenNFT.prices(1), 0.01 ether);
        assertEq(tokenNFT.prices(2), 0.02 ether);
    }

    function test_BuyToken() public {
        vm.startPrank(owner);
        deal(owner,1 ether);
        tokenNFT.addToken(1, 0.01 ether);
        tokenNFT.addToken(2, 0.02 ether);
        tokenNFT.buyToken{value:0.01 ether}(1, 1);
        tokenNFT.buyToken{value:0.02 ether}(2, 1);

        assertEq(tokenNFT.balanceOf(owner, 1), 1);
        assertEq(tokenNFT.balanceOf(owner, 2), 1);
    }

    function test_rewardUser_Success() public {
        // Simulasikan bahwa kontrak memiliki 2 ETH
        vm.deal(address(tokenNFT), 2 ether);

        // Pastikan saldo awal user adalah 0
        uint256 initialBalance = user.balance;
        
        // Panggil fungsi rewardUser dari owner
        vm.startPrank(owner);
        tokenNFT.rewardUser(payable(user), 1 ether);
        vm.stopPrank();

        // Pastikan saldo user bertambah 1 ETH
        assertEq(user.balance, initialBalance + 1 ether);
    }

    function test_rewardUser_OnlyOwner() public {
        vm.startPrank(user);
        vm.expectRevert(abi.encodeWithSelector(Ownable.OwnableUnauthorizedAccount.selector, user));
        tokenNFT.rewardUser(payable(user), 1 ether);
        vm.stopPrank();
    }

    function test_rewardUser_NotEnoughBalance() public {
        // Kontrak hanya memiliki 0.5 ETH
        vm.deal(address(tokenNFT), 0.5 ether);

        // Panggil fungsi dan harapkan transaksi gagal
        vm.startPrank(owner);
        vm.expectRevert("Not enough ETH in contract");
        tokenNFT.rewardUser(payable(user), 1 ether);
        vm.stopPrank();
    }
}