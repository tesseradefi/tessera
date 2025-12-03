// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "../interfaces/IERC20.sol";

library SafeTransfer {
    function safeTransferERC20(address token, address to, uint256 amount) internal {
        require(IERC20(token).transfer(to, amount), "ERC20 transfer failed");
    }
}