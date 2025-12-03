// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/access/AccessControl.sol";

contract TSR is ERC20, Ownable,AccessControl {
    
    uint256 public constant MAX_SUPPLY = 100_000_000 * 10**18;

    bytes32 public constant MINTER_ROLE = keccak256("MINTER_ROLE");


    constructor() ERC20("TSR", "TSR") Ownable(msg.sender){
        _grantRole(DEFAULT_ADMIN_ROLE, msg.sender);
		_grantRole(MINTER_ROLE, msg.sender);
    }

    function mint(address to, uint256 amount) external onlyRole(MINTER_ROLE) {
        require(totalSupply() + amount <= MAX_SUPPLY, "Minting exceeds max supply");
        _mint(to, amount);
    }


}