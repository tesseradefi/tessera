// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "../access/RoleControl.sol";
import "../interfaces/IERC20.sol";
import "../interfaces/IERC721.sol";
import "../utils/SafeTransfer.sol";

contract AssetManager is RoleControl {
    using SafeTransfer for address;

    event TokenWithdraw(address token, address to, uint256 amount);
    event NFTWithdraw(address nft, uint256 tokenId, address to);

    constructor() {}

    function withdrawERC20(address token, address to, uint256 amount)
        external
        onlyRole(ADMIN)
    {
        token.safeTransferERC20(to, amount);
        emit TokenWithdraw(token, to, amount);
    }

    function withdrawERC721(address nft, address to, uint256 tokenId)
        external
        onlyRole(ADMIN)
    {
        IERC721(nft).safeTransferFrom(address(this), to, tokenId);
        emit NFTWithdraw(nft, tokenId, to);
    }
}