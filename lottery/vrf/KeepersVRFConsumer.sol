// SPDX-License-Identifier: MIT
pragma solidity ^0.8.6;

import {AutomationCompatibleInterface as KeeperCompatibleInterface} from "../automation/interfaces/AutomationCompatibleInterface.sol";
import {VRFConsumerBaseV2} from "./VRFConsumerBaseV2.sol";
import {VRFCoordinatorV2Interface} from "./interfaces/VRFCoordinatorV2Interface.sol";




contract KeepersVRFConsumer is KeeperCompatibleInterface, VRFConsumerBaseV2 {
  
  
  uint256 public immutable UPKEEP_INTERVAL;

  
  VRFCoordinatorV2Interface public immutable COORDINATOR;
  uint64 public immutable SUBSCRIPTION_ID;
  uint16 public immutable REQUEST_CONFIRMATIONS;
  bytes32 public immutable KEY_HASH;

  
  uint256 public s_lastTimeStamp;
  uint256 public s_vrfRequestCounter;
  uint256 public s_vrfResponseCounter;

  struct RequestRecord {
    uint256 requestId;
    bool fulfilled;
    uint32 callbackGasLimit;
    uint256 randomness;
  }
  mapping(uint256 => RequestRecord) public s_requests;  

  constructor(
    address vrfCoordinator,
    uint64 subscriptionId,
    bytes32 keyHash,
    uint16 requestConfirmations,
    uint256 upkeepInterval
  ) VRFConsumerBaseV2(vrfCoordinator) {
    COORDINATOR = VRFCoordinatorV2Interface(vrfCoordinator);
    SUBSCRIPTION_ID = subscriptionId;
    REQUEST_CONFIRMATIONS = requestConfirmations;
    KEY_HASH = keyHash;
    UPKEEP_INTERVAL = upkeepInterval;

    s_lastTimeStamp = block.timestamp;
    s_vrfRequestCounter = 0;
    s_vrfResponseCounter = 0;
  }

  
  
  function checkUpkeep(
    bytes calldata 
  ) external view override returns (bool upkeepNeeded, bytes memory ) {
    upkeepNeeded = (block.timestamp - s_lastTimeStamp) > UPKEEP_INTERVAL;
  }

  
  function performUpkeep(bytes calldata ) external override {
    if ((block.timestamp - s_lastTimeStamp) > UPKEEP_INTERVAL) {
      s_lastTimeStamp = block.timestamp;

      _requestRandomWords();
    }
  }

  
  
  function fulfillRandomWords(uint256 requestId, uint256[] memory randomWords) internal override {
    
    RequestRecord memory record = s_requests[requestId];
    
    require(record.requestId == requestId, "request ID not found in map");

    
    s_requests[requestId].randomness = randomWords[0];
    s_vrfResponseCounter++;
  }

  
  function _requestRandomWords() internal {
    uint256 requestId = COORDINATOR.requestRandomWords(
      KEY_HASH,
      SUBSCRIPTION_ID,
      REQUEST_CONFIRMATIONS,
      150000, 
      1 
    );
    s_requests[requestId] = RequestRecord({
      requestId: requestId,
      fulfilled: false,
      callbackGasLimit: 150000,
      randomness: 0
    });
    s_vrfRequestCounter++;
  }
}
