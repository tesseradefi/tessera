// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "@openzeppelin/contracts/utils/cryptography/ECDSA.sol";

abstract contract EIP712WithSalt {
    using ECDSA for bytes32;

    bytes32 private immutable _domainSeparator;
    uint256 private immutable _chainId;

    
    bytes32 private constant DOMAIN_TYPEHASH =
        keccak256(
            "EIP712Domain(string name,string version,uint256 chainId,address verifyingContract,bytes32 salt)"
        );

    constructor(
        string memory name,
        string memory version,
        bytes32 salt
    ) {
        _chainId = block.chainid;
        _domainSeparator = keccak256(
            abi.encode(
                DOMAIN_TYPEHASH,
                keccak256(bytes(name)),
                keccak256(bytes(version)),
                _chainId,
                address(this),
                salt
            )
        );
    }

    function domainSeparator() public view returns (bytes32) {
        return _domainSeparator;
    }

    function _hashTypedDataV4(bytes32 structHash) internal view returns (bytes32) {
        return keccak256(abi.encodePacked("\x19\x01", _domainSeparator, structHash));
    }
}