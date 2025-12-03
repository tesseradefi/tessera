// SPDX-License-Identifier: MIT


pragma solidity ^0.8.20;

import {Errors} from "./Errors.sol";


library Create2 {
    
    error Create2EmptyBytecode();

    
    function deploy(uint256 amount, bytes32 salt, bytes memory bytecode) internal returns (address addr) {
        if (address(this).balance < amount) {
            revert Errors.InsufficientBalance(address(this).balance, amount);
        }
        if (bytecode.length == 0) {
            revert Create2EmptyBytecode();
        }
        assembly ("memory-safe") {
            addr := create2(amount, add(bytecode, 0x20), mload(bytecode), salt)
            
            if and(iszero(addr), not(iszero(returndatasize()))) {
                let p := mload(0x40)
                returndatacopy(p, 0, returndatasize())
                revert(p, returndatasize())
            }
        }
        if (addr == address(0)) {
            revert Errors.FailedDeployment();
        }
    }

    
    function computeAddress(bytes32 salt, bytes32 bytecodeHash) internal view returns (address) {
        return computeAddress(salt, bytecodeHash, address(this));
    }

    
    function computeAddress(bytes32 salt, bytes32 bytecodeHash, address deployer) internal pure returns (address addr) {
        assembly ("memory-safe") {
            let ptr := mload(0x40) 

            
            
            
            
            
            
            
            
            

            mstore(add(ptr, 0x40), bytecodeHash)
            mstore(add(ptr, 0x20), salt)
            mstore(ptr, deployer) 
            let start := add(ptr, 0x0b) 
            mstore8(start, 0xff)
            addr := and(keccak256(start, 85), 0xffffffffffffffffffffffffffffffffffffffff)
        }
    }
}
