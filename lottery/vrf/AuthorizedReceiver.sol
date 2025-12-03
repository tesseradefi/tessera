// SPDX-License-Identifier: MIT
pragma solidity ^0.8.6;

import {EnumerableSet} from "@openzeppelin/contracts/utils/structs/EnumerableSet.sol";
import {IAuthorizedReceiver} from "./interfaces/IAuthorizedReceiver.sol";

abstract contract AuthorizedReceiver is IAuthorizedReceiver {
  using EnumerableSet for EnumerableSet.AddressSet;

  event AuthorizedSendersChanged(address[] senders, address changedBy);

  error EmptySendersList();
  error UnauthorizedSender();
  error NotAllowedToSetSenders();

  EnumerableSet.AddressSet private s_authorizedSenders;
  address[] private s_authorizedSendersList;

  
  function setAuthorizedSenders(address[] calldata senders) external override validateAuthorizedSenderSetter {
    if (senders.length == 0) {
      revert EmptySendersList();
    }
    for (uint256 i = 0; i < s_authorizedSendersList.length; i++) {
      s_authorizedSenders.remove(s_authorizedSendersList[i]);
    }
    for (uint256 i = 0; i < senders.length; i++) {
      s_authorizedSenders.add(senders[i]);
    }
    s_authorizedSendersList = senders;
    emit AuthorizedSendersChanged(senders, msg.sender);
  }

  
  function getAuthorizedSenders() public view override returns (address[] memory) {
    return s_authorizedSendersList;
  }

  
  function isAuthorizedSender(address sender) public view override returns (bool) {
    return s_authorizedSenders.contains(sender);
  }

  
  function _canSetAuthorizedSenders() internal virtual returns (bool);

  
  function _validateIsAuthorizedSender() internal view {
    if (!isAuthorizedSender(msg.sender)) {
      revert UnauthorizedSender();
    }
  }

  
  modifier validateAuthorizedSender() {
    _validateIsAuthorizedSender();
    _;
  }

  
  modifier validateAuthorizedSenderSetter() {
    if (!_canSetAuthorizedSenders()) {
      revert NotAllowedToSetSenders();
    }
    _;
  }
}
