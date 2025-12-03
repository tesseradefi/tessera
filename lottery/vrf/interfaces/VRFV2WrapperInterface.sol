// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;


interface VRFV2WrapperInterface {
  
  function lastRequestId() external view returns (uint256);

  
  function calculateRequestPrice(uint32 _callbackGasLimit) external view returns (uint256);

  
  function estimateRequestPrice(uint32 _callbackGasLimit, uint256 _requestGasPriceWei) external view returns (uint256);
}
