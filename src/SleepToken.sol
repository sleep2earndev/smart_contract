// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

import {ERC20} from "openzeppelin-contracts/contracts/token/ERC20/ERC20.sol";
import {Ownable} from "openzeppelin-contracts/contracts/access/Ownable.sol";

// contract SleepToken is ERC20, Ownable {
//     constructor() ERC20("SleppToken", "SLP") Ownable(msg.sender) {
//         _mint(msg.sender, 1000000 * 10 ** decimals());
//     }
// }

contract SleepToken is ERC20, Ownable {
    constructor() ERC20("SleepToken", "SLP") Ownable(msg.sender) {}

        // Mint 1 juta token ke alamat deployer
        function mint(address to, uint256 amount) public onlyOwner {
        _mint(to, amount);
    }
    
}