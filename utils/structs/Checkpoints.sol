// SPDX-License-Identifier: MIT



pragma solidity ^0.8.20;

import {Math} from "../math/Math.sol";


library Checkpoints {
    
    error CheckpointUnorderedInsertion();

    struct Trace224 {
        Checkpoint224[] _checkpoints;
    }

    struct Checkpoint224 {
        uint32 _key;
        uint224 _value;
    }

    
    function push(
        Trace224 storage self,
        uint32 key,
        uint224 value
    ) internal returns (uint224 oldValue, uint224 newValue) {
        return _insert(self._checkpoints, key, value);
    }

    
    function lowerLookup(Trace224 storage self, uint32 key) internal view returns (uint224) {
        uint256 len = self._checkpoints.length;
        uint256 pos = _lowerBinaryLookup(self._checkpoints, key, 0, len);
        return pos == len ? 0 : _unsafeAccess(self._checkpoints, pos)._value;
    }

    
    function upperLookup(Trace224 storage self, uint32 key) internal view returns (uint224) {
        uint256 len = self._checkpoints.length;
        uint256 pos = _upperBinaryLookup(self._checkpoints, key, 0, len);
        return pos == 0 ? 0 : _unsafeAccess(self._checkpoints, pos - 1)._value;
    }

    
    function upperLookupRecent(Trace224 storage self, uint32 key) internal view returns (uint224) {
        uint256 len = self._checkpoints.length;

        uint256 low = 0;
        uint256 high = len;

        if (len > 5) {
            uint256 mid = len - Math.sqrt(len);
            if (key < _unsafeAccess(self._checkpoints, mid)._key) {
                high = mid;
            } else {
                low = mid + 1;
            }
        }

        uint256 pos = _upperBinaryLookup(self._checkpoints, key, low, high);

        return pos == 0 ? 0 : _unsafeAccess(self._checkpoints, pos - 1)._value;
    }

    
    function latest(Trace224 storage self) internal view returns (uint224) {
        uint256 pos = self._checkpoints.length;
        return pos == 0 ? 0 : _unsafeAccess(self._checkpoints, pos - 1)._value;
    }

    
    function latestCheckpoint(Trace224 storage self) internal view returns (bool exists, uint32 _key, uint224 _value) {
        uint256 pos = self._checkpoints.length;
        if (pos == 0) {
            return (false, 0, 0);
        } else {
            Checkpoint224 storage ckpt = _unsafeAccess(self._checkpoints, pos - 1);
            return (true, ckpt._key, ckpt._value);
        }
    }

    
    function length(Trace224 storage self) internal view returns (uint256) {
        return self._checkpoints.length;
    }

    
    function at(Trace224 storage self, uint32 pos) internal view returns (Checkpoint224 memory) {
        return self._checkpoints[pos];
    }

    
    function _insert(
        Checkpoint224[] storage self,
        uint32 key,
        uint224 value
    ) private returns (uint224 oldValue, uint224 newValue) {
        uint256 pos = self.length;

        if (pos > 0) {
            Checkpoint224 storage last = _unsafeAccess(self, pos - 1);
            uint32 lastKey = last._key;
            uint224 lastValue = last._value;

            
            if (lastKey > key) {
                revert CheckpointUnorderedInsertion();
            }

            
            if (lastKey == key) {
                last._value = value;
            } else {
                self.push(Checkpoint224({_key: key, _value: value}));
            }
            return (lastValue, value);
        } else {
            self.push(Checkpoint224({_key: key, _value: value}));
            return (0, value);
        }
    }

    
    function _upperBinaryLookup(
        Checkpoint224[] storage self,
        uint32 key,
        uint256 low,
        uint256 high
    ) private view returns (uint256) {
        while (low < high) {
            uint256 mid = Math.average(low, high);
            if (_unsafeAccess(self, mid)._key > key) {
                high = mid;
            } else {
                low = mid + 1;
            }
        }
        return high;
    }

    
    function _lowerBinaryLookup(
        Checkpoint224[] storage self,
        uint32 key,
        uint256 low,
        uint256 high
    ) private view returns (uint256) {
        while (low < high) {
            uint256 mid = Math.average(low, high);
            if (_unsafeAccess(self, mid)._key < key) {
                low = mid + 1;
            } else {
                high = mid;
            }
        }
        return high;
    }

    
    function _unsafeAccess(
        Checkpoint224[] storage self,
        uint256 pos
    ) private pure returns (Checkpoint224 storage result) {
        assembly {
            mstore(0, self.slot)
            result.slot := add(keccak256(0, 0x20), pos)
        }
    }

    struct Trace208 {
        Checkpoint208[] _checkpoints;
    }

    struct Checkpoint208 {
        uint48 _key;
        uint208 _value;
    }

    
    function push(
        Trace208 storage self,
        uint48 key,
        uint208 value
    ) internal returns (uint208 oldValue, uint208 newValue) {
        return _insert(self._checkpoints, key, value);
    }

    
    function lowerLookup(Trace208 storage self, uint48 key) internal view returns (uint208) {
        uint256 len = self._checkpoints.length;
        uint256 pos = _lowerBinaryLookup(self._checkpoints, key, 0, len);
        return pos == len ? 0 : _unsafeAccess(self._checkpoints, pos)._value;
    }

    
    function upperLookup(Trace208 storage self, uint48 key) internal view returns (uint208) {
        uint256 len = self._checkpoints.length;
        uint256 pos = _upperBinaryLookup(self._checkpoints, key, 0, len);
        return pos == 0 ? 0 : _unsafeAccess(self._checkpoints, pos - 1)._value;
    }

    
    function upperLookupRecent(Trace208 storage self, uint48 key) internal view returns (uint208) {
        uint256 len = self._checkpoints.length;

        uint256 low = 0;
        uint256 high = len;

        if (len > 5) {
            uint256 mid = len - Math.sqrt(len);
            if (key < _unsafeAccess(self._checkpoints, mid)._key) {
                high = mid;
            } else {
                low = mid + 1;
            }
        }

        uint256 pos = _upperBinaryLookup(self._checkpoints, key, low, high);

        return pos == 0 ? 0 : _unsafeAccess(self._checkpoints, pos - 1)._value;
    }

    
    function latest(Trace208 storage self) internal view returns (uint208) {
        uint256 pos = self._checkpoints.length;
        return pos == 0 ? 0 : _unsafeAccess(self._checkpoints, pos - 1)._value;
    }

    
    function latestCheckpoint(Trace208 storage self) internal view returns (bool exists, uint48 _key, uint208 _value) {
        uint256 pos = self._checkpoints.length;
        if (pos == 0) {
            return (false, 0, 0);
        } else {
            Checkpoint208 storage ckpt = _unsafeAccess(self._checkpoints, pos - 1);
            return (true, ckpt._key, ckpt._value);
        }
    }

    
    function length(Trace208 storage self) internal view returns (uint256) {
        return self._checkpoints.length;
    }

    
    function at(Trace208 storage self, uint32 pos) internal view returns (Checkpoint208 memory) {
        return self._checkpoints[pos];
    }

    
    function _insert(
        Checkpoint208[] storage self,
        uint48 key,
        uint208 value
    ) private returns (uint208 oldValue, uint208 newValue) {
        uint256 pos = self.length;

        if (pos > 0) {
            Checkpoint208 storage last = _unsafeAccess(self, pos - 1);
            uint48 lastKey = last._key;
            uint208 lastValue = last._value;

            
            if (lastKey > key) {
                revert CheckpointUnorderedInsertion();
            }

            
            if (lastKey == key) {
                last._value = value;
            } else {
                self.push(Checkpoint208({_key: key, _value: value}));
            }
            return (lastValue, value);
        } else {
            self.push(Checkpoint208({_key: key, _value: value}));
            return (0, value);
        }
    }

    
    function _upperBinaryLookup(
        Checkpoint208[] storage self,
        uint48 key,
        uint256 low,
        uint256 high
    ) private view returns (uint256) {
        while (low < high) {
            uint256 mid = Math.average(low, high);
            if (_unsafeAccess(self, mid)._key > key) {
                high = mid;
            } else {
                low = mid + 1;
            }
        }
        return high;
    }

    
    function _lowerBinaryLookup(
        Checkpoint208[] storage self,
        uint48 key,
        uint256 low,
        uint256 high
    ) private view returns (uint256) {
        while (low < high) {
            uint256 mid = Math.average(low, high);
            if (_unsafeAccess(self, mid)._key < key) {
                low = mid + 1;
            } else {
                high = mid;
            }
        }
        return high;
    }

    
    function _unsafeAccess(
        Checkpoint208[] storage self,
        uint256 pos
    ) private pure returns (Checkpoint208 storage result) {
        assembly {
            mstore(0, self.slot)
            result.slot := add(keccak256(0, 0x20), pos)
        }
    }

    struct Trace160 {
        Checkpoint160[] _checkpoints;
    }

    struct Checkpoint160 {
        uint96 _key;
        uint160 _value;
    }

    
    function push(
        Trace160 storage self,
        uint96 key,
        uint160 value
    ) internal returns (uint160 oldValue, uint160 newValue) {
        return _insert(self._checkpoints, key, value);
    }

    
    function lowerLookup(Trace160 storage self, uint96 key) internal view returns (uint160) {
        uint256 len = self._checkpoints.length;
        uint256 pos = _lowerBinaryLookup(self._checkpoints, key, 0, len);
        return pos == len ? 0 : _unsafeAccess(self._checkpoints, pos)._value;
    }

    
    function upperLookup(Trace160 storage self, uint96 key) internal view returns (uint160) {
        uint256 len = self._checkpoints.length;
        uint256 pos = _upperBinaryLookup(self._checkpoints, key, 0, len);
        return pos == 0 ? 0 : _unsafeAccess(self._checkpoints, pos - 1)._value;
    }

    
    function upperLookupRecent(Trace160 storage self, uint96 key) internal view returns (uint160) {
        uint256 len = self._checkpoints.length;

        uint256 low = 0;
        uint256 high = len;

        if (len > 5) {
            uint256 mid = len - Math.sqrt(len);
            if (key < _unsafeAccess(self._checkpoints, mid)._key) {
                high = mid;
            } else {
                low = mid + 1;
            }
        }

        uint256 pos = _upperBinaryLookup(self._checkpoints, key, low, high);

        return pos == 0 ? 0 : _unsafeAccess(self._checkpoints, pos - 1)._value;
    }

    
    function latest(Trace160 storage self) internal view returns (uint160) {
        uint256 pos = self._checkpoints.length;
        return pos == 0 ? 0 : _unsafeAccess(self._checkpoints, pos - 1)._value;
    }

    
    function latestCheckpoint(Trace160 storage self) internal view returns (bool exists, uint96 _key, uint160 _value) {
        uint256 pos = self._checkpoints.length;
        if (pos == 0) {
            return (false, 0, 0);
        } else {
            Checkpoint160 storage ckpt = _unsafeAccess(self._checkpoints, pos - 1);
            return (true, ckpt._key, ckpt._value);
        }
    }

    
    function length(Trace160 storage self) internal view returns (uint256) {
        return self._checkpoints.length;
    }

    
    function at(Trace160 storage self, uint32 pos) internal view returns (Checkpoint160 memory) {
        return self._checkpoints[pos];
    }

    
    function _insert(
        Checkpoint160[] storage self,
        uint96 key,
        uint160 value
    ) private returns (uint160 oldValue, uint160 newValue) {
        uint256 pos = self.length;

        if (pos > 0) {
            Checkpoint160 storage last = _unsafeAccess(self, pos - 1);
            uint96 lastKey = last._key;
            uint160 lastValue = last._value;

            
            if (lastKey > key) {
                revert CheckpointUnorderedInsertion();
            }

            
            if (lastKey == key) {
                last._value = value;
            } else {
                self.push(Checkpoint160({_key: key, _value: value}));
            }
            return (lastValue, value);
        } else {
            self.push(Checkpoint160({_key: key, _value: value}));
            return (0, value);
        }
    }

    
    function _upperBinaryLookup(
        Checkpoint160[] storage self,
        uint96 key,
        uint256 low,
        uint256 high
    ) private view returns (uint256) {
        while (low < high) {
            uint256 mid = Math.average(low, high);
            if (_unsafeAccess(self, mid)._key > key) {
                high = mid;
            } else {
                low = mid + 1;
            }
        }
        return high;
    }

    
    function _lowerBinaryLookup(
        Checkpoint160[] storage self,
        uint96 key,
        uint256 low,
        uint256 high
    ) private view returns (uint256) {
        while (low < high) {
            uint256 mid = Math.average(low, high);
            if (_unsafeAccess(self, mid)._key < key) {
                low = mid + 1;
            } else {
                high = mid;
            }
        }
        return high;
    }

    
    function _unsafeAccess(
        Checkpoint160[] storage self,
        uint256 pos
    ) private pure returns (Checkpoint160 storage result) {
        assembly {
            mstore(0, self.slot)
            result.slot := add(keccak256(0, 0x20), pos)
        }
    }
}
