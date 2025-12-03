// SPDX-License-Identifier: MIT


pragma solidity ^0.8.24;

import {Math} from "./math/Math.sol";


library Bytes {
    
    function indexOf(bytes memory buffer, bytes1 s) internal pure returns (uint256) {
        return indexOf(buffer, s, 0);
    }

    
    function indexOf(bytes memory buffer, bytes1 s, uint256 pos) internal pure returns (uint256) {
        uint256 length = buffer.length;
        for (uint256 i = pos; i < length; ++i) {
            if (bytes1(_unsafeReadBytesOffset(buffer, i)) == s) {
                return i;
            }
        }
        return type(uint256).max;
    }

    
    function lastIndexOf(bytes memory buffer, bytes1 s) internal pure returns (uint256) {
        return lastIndexOf(buffer, s, type(uint256).max);
    }

    
    function lastIndexOf(bytes memory buffer, bytes1 s, uint256 pos) internal pure returns (uint256) {
        unchecked {
            uint256 length = buffer.length;
            for (uint256 i = Math.min(Math.saturatingAdd(pos, 1), length); i > 0; --i) {
                if (bytes1(_unsafeReadBytesOffset(buffer, i - 1)) == s) {
                    return i - 1;
                }
            }
            return type(uint256).max;
        }
    }

    
    function slice(bytes memory buffer, uint256 start) internal pure returns (bytes memory) {
        return slice(buffer, start, buffer.length);
    }

    
    function slice(bytes memory buffer, uint256 start, uint256 end) internal pure returns (bytes memory) {
        
        uint256 length = buffer.length;
        end = Math.min(end, length);
        start = Math.min(start, end);

        
        bytes memory result = new bytes(end - start);
        assembly ("memory-safe") {
            mcopy(add(result, 0x20), add(add(buffer, 0x20), start), sub(end, start))
        }

        return result;
    }

    
    function _unsafeReadBytesOffset(bytes memory buffer, uint256 offset) private pure returns (bytes32 value) {
        
        assembly ("memory-safe") {
            value := mload(add(add(buffer, 0x20), offset))
        }
    }
}
