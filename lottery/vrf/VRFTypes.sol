// SPDX-License-Identifier: MIT
pragma solidity ^0.8.6;


library VRFTypes {
  
  
  struct Proof {
    uint256[2] pk;
    uint256[2] gamma;
    uint256 c;
    uint256 s;
    uint256 seed;
    address uWitness;
    uint256[2] cGammaWitness;
    uint256[2] sHashWitness;
    uint256 zInv;
  }

  
  
  struct RequestCommitment {
    uint64 blockNum;
    uint64 subId;
    uint32 callbackGasLimit;
    uint32 numWords;
    address sender;
  }

  
  
  struct RequestCommitmentV2Plus {
    uint64 blockNum;
    uint256 subId;
    uint32 callbackGasLimit;
    uint32 numWords;
    address sender;
    bytes extraArgs;
  }
}
