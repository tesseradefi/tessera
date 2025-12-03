// SPDX-License-Identifier: MIT

pragma solidity 0.8.19;

import {ChainSpecificUtil} from "../shared/util/ChainSpecificUtil.sol";


contract BatchBlockhashStore {
  
  BlockhashStore public immutable BHS;

  constructor(address blockhashStoreAddr) {
    BHS = BlockhashStore(blockhashStoreAddr);
  }

  
  function store(uint256[] memory blockNumbers) public {
    for (uint256 i = 0; i < blockNumbers.length; i++) {
      
      
      if (!_storeableBlock(blockNumbers[i])) {
        continue;
      }
      BHS.store(blockNumbers[i]);
    }
  }

  
  function storeVerifyHeader(uint256[] memory blockNumbers, bytes[] memory headers) public {
    
    require(blockNumbers.length == headers.length, "input array arg lengths mismatch");
    for (uint256 i = 0; i < blockNumbers.length; i++) {
      BHS.storeVerifyHeader(blockNumbers[i], headers[i]);
    }
  }

  
  function getBlockhashes(uint256[] memory blockNumbers) external view returns (bytes32[] memory) {
    bytes32[] memory blockHashes = new bytes32[](blockNumbers.length);
    for (uint256 i = 0; i < blockNumbers.length; i++) {
      try BHS.getBlockhash(blockNumbers[i]) returns (bytes32 bh) {
        blockHashes[i] = bh;
      } catch Error(string memory ) {
        blockHashes[i] = 0x0;
      }
    }
    return blockHashes;
  }

  
  function _storeableBlock(uint256 blockNumber) private view returns (bool) {
    
    return
      ChainSpecificUtil._getBlockNumber() <= 256 ? true : blockNumber >= (ChainSpecificUtil._getBlockNumber() - 256);
  }
}


interface BlockhashStore {
  function storeVerifyHeader(uint256 n, bytes memory header) external;

  function store(uint256 n) external;

  function getBlockhash(uint256 n) external view returns (bytes32);
}
