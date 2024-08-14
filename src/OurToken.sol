// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

import {ERC20} from "@openzeppelin/contracts/token/ERC20/ERC20.sol";

contract OurToken is ERC20 {
    constructor(uint256 initialSupply) ERC20("OurToken", "OT") {
        _mint(msg.sender, initialSupply);
    }

    // Public mint function for testing purposes
    function mint(address to, uint256 amount) public {
        _mint(to, amount);
    }

    // Public burn function for testing purposes
    function burn(uint256 amount) public {
        _burn(msg.sender, amount);
    }
}
