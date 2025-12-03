// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;


contract VRF {
  
  
  uint256 private constant GROUP_ORDER = 0xFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFEBAAEDCE6AF48A03BBFD25E8CD0364141;
  
  uint256 private constant FIELD_SIZE =
    
    0xFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFEFFFFFC2F;
  uint256 private constant WORD_LENGTH_BYTES = 0x20;

  
  
  function _bigModExp(uint256 base, uint256 exponent) internal view returns (uint256 exponentiation) {
    uint256 callResult;
    uint256[6] memory bigModExpContractInputs;
    bigModExpContractInputs[0] = WORD_LENGTH_BYTES; 
    bigModExpContractInputs[1] = WORD_LENGTH_BYTES; 
    bigModExpContractInputs[2] = WORD_LENGTH_BYTES; 
    bigModExpContractInputs[3] = base;
    bigModExpContractInputs[4] = exponent;
    bigModExpContractInputs[5] = FIELD_SIZE;
    uint256[1] memory output;
    assembly {
      callResult := staticcall(
        not(0), 
        0x05, 
        bigModExpContractInputs,
        0xc0, 
        output,
        0x20 
      )
    }
    if (callResult == 0) {
      
      revert("bigModExp failure!");
    }
    return output[0];
  }

  
  
  uint256 private constant SQRT_POWER = (FIELD_SIZE + 1) >> 2;

  
  function _squareRoot(uint256 x) internal view returns (uint256) {
    return _bigModExp(x, SQRT_POWER);
  }

  
  function _ySquared(uint256 x) internal pure returns (uint256) {
    
    uint256 xCubed = mulmod(x, mulmod(x, x, FIELD_SIZE), FIELD_SIZE);
    return addmod(xCubed, 7, FIELD_SIZE);
  }

  
  function _isOnCurve(uint256[2] memory p) internal pure returns (bool) {
    
    
    
    require(p[0] < FIELD_SIZE, "invalid x-ordinate");
    
    require(p[1] < FIELD_SIZE, "invalid y-ordinate");
    return _ySquared(p[0]) == mulmod(p[1], p[1], FIELD_SIZE);
  }

  
  function _fieldHash(bytes memory b) internal pure returns (uint256 x_) {
    x_ = uint256(keccak256(b));
    
    
    
    while (x_ >= FIELD_SIZE) {
      x_ = uint256(keccak256(abi.encodePacked(x_)));
    }
    return x_;
  }

  
  
  
  
  
  
  function _newCandidateSecp256k1Point(bytes memory b) internal view returns (uint256[2] memory p) {
    unchecked {
      p[0] = _fieldHash(b);
      p[1] = _squareRoot(_ySquared(p[0]));
      if (p[1] % 2 == 1) {
        
        
        p[1] = FIELD_SIZE - p[1];
      }
    }
    return p;
  }

  
  
  uint256 internal constant HASH_TO_CURVE_HASH_PREFIX = 1;

  
  
  
  
  
  
  
  
  
  
  
  
  
  
  function _hashToCurve(uint256[2] memory pk, uint256 input) internal view returns (uint256[2] memory rv) {
    rv = _newCandidateSecp256k1Point(abi.encodePacked(HASH_TO_CURVE_HASH_PREFIX, pk, input));
    while (!_isOnCurve(rv)) {
      rv = _newCandidateSecp256k1Point(abi.encodePacked(rv[0]));
    }
    return rv;
  }

  
  function _ecmulVerify(
    uint256[2] memory multiplicand,
    uint256 scalar,
    uint256[2] memory product
  ) internal pure returns (bool verifies) {
    
    require(scalar != 0, "zero scalar"); 
    uint256 x = multiplicand[0]; 
    uint8 v = multiplicand[1] % 2 == 0 ? 27 : 28; 
    
    
    
    
    bytes32 scalarTimesX = bytes32(mulmod(scalar, x, GROUP_ORDER));
    address actual = ecrecover(bytes32(0), v, bytes32(x), scalarTimesX);
    
    address expected = address(uint160(uint256(keccak256(abi.encodePacked(product)))));
    return (actual == expected);
  }

  
  function _projectiveSub(
    uint256 x1,
    uint256 z1,
    uint256 x2,
    uint256 z2
  ) internal pure returns (uint256 x3, uint256 z3) {
    unchecked {
      uint256 num1 = mulmod(z2, x1, FIELD_SIZE);
      
      
      uint256 num2 = mulmod(FIELD_SIZE - x2, z1, FIELD_SIZE);
      (x3, z3) = (addmod(num1, num2, FIELD_SIZE), mulmod(z1, z2, FIELD_SIZE));
    }
    return (x3, z3);
  }

  
  function _projectiveMul(
    uint256 x1,
    uint256 z1,
    uint256 x2,
    uint256 z2
  ) internal pure returns (uint256 x3, uint256 z3) {
    (x3, z3) = (mulmod(x1, x2, FIELD_SIZE), mulmod(z1, z2, FIELD_SIZE));
    return (x3, z3);
  }

  
  function _projectiveECAdd(
    uint256 px,
    uint256 py,
    uint256 qx,
    uint256 qy
  ) internal pure returns (uint256 sx, uint256 sy, uint256 sz) {
    unchecked {
      
      
      
      
      

      
      
      

      
      (uint256 z1, uint256 z2) = (1, 1);

      
      
      uint256 lx = addmod(qy, FIELD_SIZE - py, FIELD_SIZE);
      uint256 lz = addmod(qx, FIELD_SIZE - px, FIELD_SIZE);

      uint256 dx; 
      
      (sx, dx) = _projectiveMul(lx, lz, lx, lz); 
      (sx, dx) = _projectiveSub(sx, dx, px, z1); 
      (sx, dx) = _projectiveSub(sx, dx, qx, z2); 

      uint256 dy; 
      
      (sy, dy) = _projectiveSub(px, z1, sx, dx); 
      (sy, dy) = _projectiveMul(sy, dy, lx, lz); 
      (sy, dy) = _projectiveSub(sy, dy, py, z1); 

      if (dx != dy) {
        
        sx = mulmod(sx, dy, FIELD_SIZE);
        sy = mulmod(sy, dx, FIELD_SIZE);
        sz = mulmod(dx, dy, FIELD_SIZE);
      } else {
        
        sz = dx;
      }
    }
    return (sx, sy, sz);
  }

  
  
  
  
  
  
  
  function _affineECAdd(
    uint256[2] memory p1,
    uint256[2] memory p2,
    uint256 invZ
  ) internal pure returns (uint256[2] memory) {
    uint256 x;
    uint256 y;
    uint256 z;
    (x, y, z) = _projectiveECAdd(p1[0], p1[1], p2[0], p2[1]);
    
    require(mulmod(z, invZ, FIELD_SIZE) == 1, "invZ must be inverse of z");
    
    
    return [mulmod(x, invZ, FIELD_SIZE), mulmod(y, invZ, FIELD_SIZE)];
  }

  
  
  function _verifyLinearCombinationWithGenerator(
    uint256 c,
    uint256[2] memory p,
    uint256 s,
    address lcWitness
  ) internal pure returns (bool) {
    
    unchecked {
      
      require(lcWitness != address(0), "bad witness");
      uint8 v = (p[1] % 2 == 0) ? 27 : 28; 
      
      
      bytes32 pseudoHash = bytes32(GROUP_ORDER - mulmod(p[0], s, GROUP_ORDER)); 
      bytes32 pseudoSignature = bytes32(mulmod(c, p[0], GROUP_ORDER)); 
      
      
      
      
      
      
      address computed = ecrecover(pseudoHash, v, bytes32(p[0]), pseudoSignature);
      return computed == lcWitness;
    }
  }

  
  
  
  
  
  
  
  function _linearCombination(
    uint256 c,
    uint256[2] memory p1,
    uint256[2] memory cp1Witness,
    uint256 s,
    uint256[2] memory p2,
    uint256[2] memory sp2Witness,
    uint256 zInv
  ) internal pure returns (uint256[2] memory) {
    unchecked {
      
      
      require((cp1Witness[0] % FIELD_SIZE) != (sp2Witness[0] % FIELD_SIZE), "points in sum must be distinct");
      
      require(_ecmulVerify(p1, c, cp1Witness), "First mul check failed");
      
      require(_ecmulVerify(p2, s, sp2Witness), "Second mul check failed");
      return _affineECAdd(cp1Witness, sp2Witness, zInv);
    }
  }

  
  
  uint256 internal constant SCALAR_FROM_CURVE_POINTS_HASH_PREFIX = 2;

  
  
  
  
  
  
  
  
  
  
  
  function _scalarFromCurvePoints(
    uint256[2] memory hash,
    uint256[2] memory pk,
    uint256[2] memory gamma,
    address uWitness,
    uint256[2] memory v
  ) internal pure returns (uint256 s) {
    return uint256(keccak256(abi.encodePacked(SCALAR_FROM_CURVE_POINTS_HASH_PREFIX, hash, pk, gamma, v, uWitness)));
  }

  
  
  
  
  
  
  
  
  
  function _verifyVRFProof(
    uint256[2] memory pk,
    uint256[2] memory gamma,
    uint256 c,
    uint256 s,
    uint256 seed,
    address uWitness,
    uint256[2] memory cGammaWitness,
    uint256[2] memory sHashWitness,
    uint256 zInv
  ) internal view {
    unchecked {
      
      require(_isOnCurve(pk), "public key is not on curve");
      
      require(_isOnCurve(gamma), "gamma is not on curve");
      
      require(_isOnCurve(cGammaWitness), "cGammaWitness is not on curve");
      
      require(_isOnCurve(sHashWitness), "sHashWitness is not on curve");
      
      
      
      
      
      
      require(_verifyLinearCombinationWithGenerator(c, pk, s, uWitness), "addr(c*pk+s*g)!=_uWitness");
      
      uint256[2] memory hash = _hashToCurve(pk, seed);
      
      uint256[2] memory v = _linearCombination(c, gamma, cGammaWitness, s, hash, sHashWitness, zInv);
      
      uint256 derivedC = _scalarFromCurvePoints(hash, pk, gamma, uWitness, v);
      
      require(c == derivedC, "invalid proof");
    }
  }

  
  
  uint256 internal constant VRF_RANDOM_OUTPUT_HASH_PREFIX = 3;

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

  
  function _randomValueFromVRFProof(Proof calldata proof, uint256 seed) internal view returns (uint256 output) {
    _verifyVRFProof(
      proof.pk,
      proof.gamma,
      proof.c,
      proof.s,
      seed,
      proof.uWitness,
      proof.cGammaWitness,
      proof.sHashWitness,
      proof.zInv
    );
    output = uint256(keccak256(abi.encode(VRF_RANDOM_OUTPUT_HASH_PREFIX, proof.gamma)));
    return output;
  }
}
