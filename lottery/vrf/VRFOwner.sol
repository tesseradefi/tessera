// SPDX-License-Identifier: MIT

pragma solidity ^0.8.6;

import {ConfirmedOwner} from "../shared/access/ConfirmedOwner.sol";
import {AuthorizedReceiver} from "./AuthorizedReceiver.sol";
import {VRFTypes} from "./VRFTypes.sol";



struct FeeConfig {
  
  
  uint32 fulfillmentFlatFeeLinkPPMTier1;
  uint32 fulfillmentFlatFeeLinkPPMTier2;
  uint32 fulfillmentFlatFeeLinkPPMTier3;
  uint32 fulfillmentFlatFeeLinkPPMTier4;
  uint32 fulfillmentFlatFeeLinkPPMTier5;
  uint24 reqsForTier2;
  uint24 reqsForTier3;
  uint24 reqsForTier4;
  uint24 reqsForTier5;
}



struct Config {
  uint16 minimumRequestConfirmations;
  uint32 maxGasLimit;
  
  
  uint32 stalenessSeconds;
  
  
  uint32 gasAfterPaymentCalculation;
  int256 fallbackWeiPerUnitLink;
  FeeConfig feeConfig;
}



interface IVRFCoordinatorV2 {
  function acceptOwnership() external;

  function transferOwnership(address to) external;

  function registerProvingKey(address oracle, uint256[2] calldata publicProvingKey) external;

  function deregisterProvingKey(uint256[2] calldata publicProvingKey) external;

  function setConfig(
    uint16 minimumRequestConfirmations,
    uint32 maxGasLimit,
    uint32 stalenessSeconds,
    uint32 gasAfterPaymentCalculation,
    int256 fallbackWeiPerUnitLink,
    FeeConfig memory feeConfig
  ) external;

  function getConfig()
    external
    view
    returns (
      uint16 minimumRequestConfirmations,
      uint32 maxGasLimit,
      uint32 stalenessSeconds,
      uint32 gasAfterPaymentCalculation
    );

  function getFeeConfig()
    external
    view
    returns (
      uint32 fulfillmentFlatFeeLinkPPMTier1,
      uint32 fulfillmentFlatFeeLinkPPMTier2,
      uint32 fulfillmentFlatFeeLinkPPMTier3,
      uint32 fulfillmentFlatFeeLinkPPMTier4,
      uint32 fulfillmentFlatFeeLinkPPMTier5,
      uint24 reqsForTier2,
      uint24 reqsForTier3,
      uint24 reqsForTier4,
      uint24 reqsForTier5
    );

  function getFallbackWeiPerUnitLink() external view returns (int256);

  function ownerCancelSubscription(uint64 subId) external;

  function recoverFunds(address to) external;

  function hashOfKey(uint256[2] memory publicKey) external pure returns (bytes32);

  function fulfillRandomWords(
    VRFTypes.Proof calldata proof,
    VRFTypes.RequestCommitment memory rc
  ) external returns (uint96);
}


contract VRFOwner is ConfirmedOwner, AuthorizedReceiver {
  int256 private constant MAX_INT256 = 0x7fffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff;

  IVRFCoordinatorV2 internal s_vrfCoordinator;

  event RandomWordsForced(uint256 indexed requestId, uint64 indexed subId, address indexed sender);

  constructor(address _vrfCoordinator) ConfirmedOwner(msg.sender) {
    
    require(_vrfCoordinator != address(0), "vrf coordinator address must be non-zero");
    s_vrfCoordinator = IVRFCoordinatorV2(_vrfCoordinator);
  }

  
  function acceptVRFOwnership() external onlyOwner {
    s_vrfCoordinator.acceptOwnership();
  }

  
  function transferVRFOwnership(address to) external onlyOwner {
    s_vrfCoordinator.transferOwnership(to);
  }

  
  function getVRFCoordinator() public view returns (address) {
    return address(s_vrfCoordinator);
  }

  
  function registerProvingKey(address oracle, uint256[2] calldata publicProvingKey) external onlyOwner {
    s_vrfCoordinator.registerProvingKey(oracle, publicProvingKey);
  }

  
  function deregisterProvingKey(uint256[2] calldata publicProvingKey) external onlyOwner {
    s_vrfCoordinator.deregisterProvingKey(publicProvingKey);
  }

  
  function setConfig(
    uint16 minimumRequestConfirmations,
    uint32 maxGasLimit,
    uint32 stalenessSeconds,
    uint32 gasAfterPaymentCalculation,
    int256 fallbackWeiPerUnitLink,
    FeeConfig memory feeConfig
  ) public onlyOwner {
    s_vrfCoordinator.setConfig(
      minimumRequestConfirmations,
      maxGasLimit,
      stalenessSeconds,
      gasAfterPaymentCalculation,
      fallbackWeiPerUnitLink,
      feeConfig
    );
  }

  
  function _setConfig(
    uint16 minimumRequestConfirmations,
    uint32 maxGasLimit,
    uint32 stalenessSeconds,
    uint32 gasAfterPaymentCalculation,
    int256 fallbackWeiPerUnitLink,
    FeeConfig memory feeConfig
  ) private {
    s_vrfCoordinator.setConfig(
      minimumRequestConfirmations,
      maxGasLimit,
      stalenessSeconds,
      gasAfterPaymentCalculation,
      fallbackWeiPerUnitLink,
      feeConfig
    );
  }

  
  function ownerCancelSubscription(uint64 subId) external onlyOwner {
    s_vrfCoordinator.ownerCancelSubscription(subId);
  }

  
  function recoverFunds(address to) external onlyOwner {
    s_vrfCoordinator.recoverFunds(to);
  }

  
  function _getConfigs() private view returns (Config memory) {
    (
      uint16 minimumRequestConfirmations,
      uint32 maxGasLimit,
      uint32 stalenessSeconds,
      uint32 gasAfterPaymentCalculation
    ) = s_vrfCoordinator.getConfig();
    (
      uint32 fulfillmentFlatFeeLinkPPMTier1,
      uint32 fulfillmentFlatFeeLinkPPMTier2,
      uint32 fulfillmentFlatFeeLinkPPMTier3,
      uint32 fulfillmentFlatFeeLinkPPMTier4,
      uint32 fulfillmentFlatFeeLinkPPMTier5,
      uint24 reqsForTier2,
      uint24 reqsForTier3,
      uint24 reqsForTier4,
      uint24 reqsForTier5
    ) = s_vrfCoordinator.getFeeConfig();
    int256 fallbackWeiPerUnitLink = s_vrfCoordinator.getFallbackWeiPerUnitLink();
    return
      Config({
        minimumRequestConfirmations: minimumRequestConfirmations,
        maxGasLimit: maxGasLimit,
        stalenessSeconds: stalenessSeconds,
        gasAfterPaymentCalculation: gasAfterPaymentCalculation,
        fallbackWeiPerUnitLink: fallbackWeiPerUnitLink,
        feeConfig: FeeConfig({
          fulfillmentFlatFeeLinkPPMTier1: fulfillmentFlatFeeLinkPPMTier1,
          fulfillmentFlatFeeLinkPPMTier2: fulfillmentFlatFeeLinkPPMTier2,
          fulfillmentFlatFeeLinkPPMTier3: fulfillmentFlatFeeLinkPPMTier3,
          fulfillmentFlatFeeLinkPPMTier4: fulfillmentFlatFeeLinkPPMTier4,
          fulfillmentFlatFeeLinkPPMTier5: fulfillmentFlatFeeLinkPPMTier5,
          reqsForTier2: reqsForTier2,
          reqsForTier3: reqsForTier3,
          reqsForTier4: reqsForTier4,
          reqsForTier5: reqsForTier5
        })
      });
  }

  
  function fulfillRandomWords(
    VRFTypes.Proof calldata proof,
    VRFTypes.RequestCommitment memory rc
  ) external validateAuthorizedSender {
    uint256 requestId = _requestIdFromProof(proof.pk, proof.seed);

    
    
    Config memory cfg = _getConfigs();

    
    
    _setConfig(
      cfg.minimumRequestConfirmations,
      cfg.maxGasLimit,
      1, 
      0, 
      MAX_INT256, 
      FeeConfig({
        fulfillmentFlatFeeLinkPPMTier1: 0,
        fulfillmentFlatFeeLinkPPMTier2: 0,
        fulfillmentFlatFeeLinkPPMTier3: 0,
        fulfillmentFlatFeeLinkPPMTier4: 0,
        fulfillmentFlatFeeLinkPPMTier5: 0,
        reqsForTier2: 0,
        reqsForTier3: 0,
        reqsForTier4: 0,
        reqsForTier5: 0
      })
    );

    s_vrfCoordinator.fulfillRandomWords(proof, rc);

    
    _setConfig(
      cfg.minimumRequestConfirmations,
      cfg.maxGasLimit,
      cfg.stalenessSeconds,
      cfg.gasAfterPaymentCalculation,
      cfg.fallbackWeiPerUnitLink,
      cfg.feeConfig
    );

    emit RandomWordsForced(requestId, rc.subId, rc.sender);
  }

  
  function _canSetAuthorizedSenders() internal view override returns (bool) {
    return owner() == msg.sender;
  }

  
  function _requestIdFromProof(uint256[2] memory publicKey, uint256 proofSeed) private view returns (uint256) {
    bytes32 keyHash = s_vrfCoordinator.hashOfKey(publicKey);
    uint256 requestId = uint256(keccak256(abi.encode(keyHash, proofSeed)));
    return requestId;
  }
}
