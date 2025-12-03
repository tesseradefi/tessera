// SPDX-License-Identifier: MIT

pragma solidity ^0.8.6;

import {ConfirmedOwner} from "../shared/access/ConfirmedOwner.sol";
import {ITypeAndVersion} from "../shared/interfaces/ITypeAndVersion.sol";
import {VRFConsumerBaseV2} from "./VRFConsumerBaseV2.sol";
import {LinkTokenInterface} from "../shared/interfaces/LinkTokenInterface.sol";
import {AggregatorV3Interface} from "../shared/interfaces/AggregatorV3Interface.sol";
import {VRFCoordinatorV2Interface} from "./interfaces/VRFCoordinatorV2Interface.sol";
import {VRFV2WrapperInterface} from "./interfaces/VRFV2WrapperInterface.sol";
import {VRFV2WrapperConsumerBase} from "./VRFV2WrapperConsumerBase.sol";
import {ChainSpecificUtil} from "./ChainSpecificUtil_v0_8_6.sol";


contract VRFV2Wrapper is ConfirmedOwner, ITypeAndVersion, VRFConsumerBaseV2, VRFV2WrapperInterface {
  event WrapperFulfillmentFailed(uint256 indexed requestId, address indexed consumer);

  
  LinkTokenInterface public immutable LINK;
  
  AggregatorV3Interface public immutable LINK_ETH_FEED;
  
  ExtendedVRFCoordinatorV2Interface public immutable COORDINATOR;
  
  uint64 public immutable SUBSCRIPTION_ID;
  
  
  
  
  
  
  uint32 public s_fulfillmentTxSizeBytes = 580;

  
  
  uint256 private constant GAS_FOR_CALL_EXACT_CHECK = 5_000;

  
  
  uint256 public override lastRequestId;

  

  
  
  bool public s_configured;

  
  
  bool public s_disabled;

  
  
  int256 private s_fallbackWeiPerUnitLink;

  
  
  uint32 private s_stalenessSeconds;

  
  
  uint32 private s_fulfillmentFlatFeeLinkPPM;

  

  
  
  uint32 private s_wrapperGasOverhead;

  
  
  
  
  uint32 private s_coordinatorGasOverhead;

  
  
  uint8 private s_wrapperPremiumPercentage;

  
  
  bytes32 internal s_keyHash;

  
  uint8 internal s_maxNumWords;

  struct Callback {
    address callbackAddress;
    uint32 callbackGasLimit;
    uint256 requestGasPrice;
    int256 requestWeiPerUnitLink;
    uint256 juelsPaid;
  }
  mapping(uint256 => Callback)   public s_callbacks;

  constructor(
    address _link,
    address _linkEthFeed,
    address _coordinator
  ) ConfirmedOwner(msg.sender) VRFConsumerBaseV2(_coordinator) {
    LINK = LinkTokenInterface(_link);
    LINK_ETH_FEED = AggregatorV3Interface(_linkEthFeed);
    COORDINATOR = ExtendedVRFCoordinatorV2Interface(_coordinator);

    
    uint64 subId = ExtendedVRFCoordinatorV2Interface(_coordinator).createSubscription();
    SUBSCRIPTION_ID = subId;
    ExtendedVRFCoordinatorV2Interface(_coordinator).addConsumer(subId, address(this));
  }

  
  function setFulfillmentTxSize(uint32 size) external onlyOwner {
    s_fulfillmentTxSizeBytes = size;
  }

  
  function setConfig(
    uint32 _wrapperGasOverhead,
    uint32 _coordinatorGasOverhead,
    uint8 _wrapperPremiumPercentage,
    bytes32 _keyHash,
    uint8 _maxNumWords
  ) external onlyOwner {
    s_wrapperGasOverhead = _wrapperGasOverhead;
    s_coordinatorGasOverhead = _coordinatorGasOverhead;
    s_wrapperPremiumPercentage = _wrapperPremiumPercentage;
    s_keyHash = _keyHash;
    s_maxNumWords = _maxNumWords;
    s_configured = true;

    
    (, , s_stalenessSeconds, ) = COORDINATOR.getConfig();
    s_fallbackWeiPerUnitLink = COORDINATOR.getFallbackWeiPerUnitLink();
    (s_fulfillmentFlatFeeLinkPPM, , , , , , , , ) = COORDINATOR.getFeeConfig();
  }

  
  function getConfig()
    external
    view
    returns (
      int256 fallbackWeiPerUnitLink,
      uint32 stalenessSeconds,
      uint32 fulfillmentFlatFeeLinkPPM,
      uint32 wrapperGasOverhead,
      uint32 coordinatorGasOverhead,
      uint8 wrapperPremiumPercentage,
      bytes32 keyHash,
      uint8 maxNumWords
    )
  {
    return (
      s_fallbackWeiPerUnitLink,
      s_stalenessSeconds,
      s_fulfillmentFlatFeeLinkPPM,
      s_wrapperGasOverhead,
      s_coordinatorGasOverhead,
      s_wrapperPremiumPercentage,
      s_keyHash,
      s_maxNumWords
    );
  }

  
  function calculateRequestPrice(
    uint32 _callbackGasLimit
  ) external view override onlyConfiguredNotDisabled returns (uint256) {
    int256 weiPerUnitLink = _getFeedData();
    return _calculateRequestPrice(_callbackGasLimit, tx.gasprice, weiPerUnitLink);
  }

  
  function estimateRequestPrice(
    uint32 _callbackGasLimit,
    uint256 _requestGasPriceWei
  ) external view override onlyConfiguredNotDisabled returns (uint256) {
    int256 weiPerUnitLink = _getFeedData();
    return _calculateRequestPrice(_callbackGasLimit, _requestGasPriceWei, weiPerUnitLink);
  }

  function _calculateRequestPrice(
    uint256 _gas,
    uint256 _requestGasPrice,
    int256 _weiPerUnitLink
  ) internal view returns (uint256) {
    
    
    
    uint256 costWei = (_requestGasPrice *
      (_gas + s_wrapperGasOverhead + s_coordinatorGasOverhead) +
      ChainSpecificUtil._getL1CalldataGasCost(s_fulfillmentTxSizeBytes));
    
    
    uint256 baseFee = (1e18 * costWei) / uint256(_weiPerUnitLink);
    
    uint256 feeWithPremium = (baseFee * (s_wrapperPremiumPercentage + 100)) / 100;
    
    uint256 feeWithFlatFee = feeWithPremium + (1e12 * uint256(s_fulfillmentFlatFeeLinkPPM));

    return feeWithFlatFee;
  }

  
  function onTokenTransfer(address _sender, uint256 _amount, bytes calldata _data) external onlyConfiguredNotDisabled {
    
    require(msg.sender == address(LINK), "only callable from LINK");

    (uint32 callbackGasLimit, uint16 requestConfirmations, uint32 numWords) = abi.decode(
      _data,
      (uint32, uint16, uint32)
    );
    uint32 eip150Overhead = _getEIP150Overhead(callbackGasLimit);
    int256 weiPerUnitLink = _getFeedData();
    uint256 price = _calculateRequestPrice(callbackGasLimit, tx.gasprice, weiPerUnitLink);
    
    require(_amount >= price, "fee too low");
    
    require(numWords <= s_maxNumWords, "numWords too high");

    uint256 requestId = COORDINATOR.requestRandomWords(
      s_keyHash,
      SUBSCRIPTION_ID,
      requestConfirmations,
      callbackGasLimit + eip150Overhead + s_wrapperGasOverhead,
      numWords
    );
    s_callbacks[requestId] = Callback({
      callbackAddress: _sender,
      callbackGasLimit: callbackGasLimit,
      requestGasPrice: tx.gasprice,
      requestWeiPerUnitLink: weiPerUnitLink,
      juelsPaid: _amount
    });
    lastRequestId = requestId;
  }

  
  function withdraw(address _recipient, uint256 _amount) external onlyOwner {
    LINK.transfer(_recipient, _amount);
  }

  
  function enable() external onlyOwner {
    s_disabled = false;
  }

  
  function disable() external onlyOwner {
    s_disabled = true;
  }

  
  function fulfillRandomWords(uint256 _requestId, uint256[] memory _randomWords) internal override {
    Callback memory callback = s_callbacks[_requestId];
    delete s_callbacks[_requestId];
    
    require(callback.callbackAddress != address(0), "request not found"); 

    VRFV2WrapperConsumerBase c;
    bytes memory resp = abi.encodeWithSelector(c.rawFulfillRandomWords.selector, _requestId, _randomWords);

    bool success = _callWithExactGas(callback.callbackGasLimit, callback.callbackAddress, resp);
    if (!success) {
      emit WrapperFulfillmentFailed(_requestId, callback.callbackAddress);
    }
  }

  function _getFeedData() private view returns (int256) {
    bool staleFallback = s_stalenessSeconds > 0;
    uint256 timestamp;
    int256 weiPerUnitLink;
    (, weiPerUnitLink, , timestamp, ) = LINK_ETH_FEED.latestRoundData();
    
    if (staleFallback && s_stalenessSeconds < block.timestamp - timestamp) {
      weiPerUnitLink = s_fallbackWeiPerUnitLink;
    }
    
    require(weiPerUnitLink >= 0, "Invalid LINK wei price");
    return weiPerUnitLink;
  }

  
  function _getEIP150Overhead(uint32 gas) private pure returns (uint32) {
    return gas / 63 + 1;
  }

  
  function _callWithExactGas(uint256 gasAmount, address target, bytes memory data) private returns (bool success) {
    assembly {
      let g := gas()
      
      
      
      
      
      
      if lt(g, GAS_FOR_CALL_EXACT_CHECK) {
        revert(0, 0)
      }
      g := sub(g, GAS_FOR_CALL_EXACT_CHECK)
      
      
      if iszero(gt(sub(g, div(g, 64)), gasAmount)) {
        revert(0, 0)
      }
      
      if iszero(extcodesize(target)) {
        revert(0, 0)
      }
      
      
      success := call(gasAmount, target, 0, add(data, 0x20), mload(data), 0, 0)
    }
    return success;
  }

  function typeAndVersion() external pure virtual override returns (string memory) {
    return "VRFV2Wrapper 1.0.0";
  }

  modifier onlyConfiguredNotDisabled() {
    
    require(s_configured, "wrapper is not configured");
    
    require(!s_disabled, "wrapper is disabled");
    _;
  }
}


interface ExtendedVRFCoordinatorV2Interface is VRFCoordinatorV2Interface {
  function getConfig()
    external
    view
    returns (
      uint16 minimumRequestConfirmations,
      uint32 maxGasLimit,
      uint32 stalenessSeconds,
      uint32 gasAfterPaymentCalculation
    );

  function getFallbackWeiPerUnitLink() external view returns (int256);

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
}
