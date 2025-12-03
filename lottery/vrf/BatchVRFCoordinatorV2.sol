// SPDX-License-Identifier: MIT

pragma solidity 0.8.6;

import {VRFTypes} from "./VRFTypes.sol";


contract BatchVRFCoordinatorV2 {
  
  VRFCoordinatorV2 public immutable COORDINATOR;

  event ErrorReturned(uint256 indexed requestId, string reason);
  event RawErrorReturned(uint256 indexed requestId, bytes lowLevelData);

  constructor(address coordinatorAddr) {
    COORDINATOR = VRFCoordinatorV2(coordinatorAddr);
  }

  
  function fulfillRandomWords(VRFTypes.Proof[] calldata proofs, VRFTypes.RequestCommitment[] memory rcs) external {
    
    require(proofs.length == rcs.length, "input array arg lengths mismatch");
    for (uint256 i = 0; i < proofs.length; i++) {
      try COORDINATOR.fulfillRandomWords(proofs[i], rcs[i]) returns (uint96 ) {
        continue;
      } catch Error(string memory reason) {
        uint256 requestId = _getRequestIdFromProof(proofs[i]);
        emit ErrorReturned(requestId, reason);
      } catch (bytes memory lowLevelData) {
        uint256 requestId = _getRequestIdFromProof(proofs[i]);
        emit RawErrorReturned(requestId, lowLevelData);
      }
    }
  }

  
  function _hashOfKey(uint256[2] memory publicKey) internal pure returns (bytes32) {
    return keccak256(abi.encode(publicKey));
  }

  
  function _getRequestIdFromProof(VRFTypes.Proof memory proof) internal pure returns (uint256) {
    bytes32 keyHash = _hashOfKey(proof.pk);
    return uint256(keccak256(abi.encode(keyHash, proof.seed)));
  }
}


interface VRFCoordinatorV2 {
  function fulfillRandomWords(
    VRFTypes.Proof calldata proof,
    VRFTypes.RequestCommitment memory rc
  ) external returns (uint96);
}
