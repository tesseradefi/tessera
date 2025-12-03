// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "../interfaces/IERC20.sol";
import "../utils/SafeTransfer.sol";
import "../access/RoleControl.sol";

contract TokenSwap is RoleControl {
    using SafeTransfer for address;

    address public tokenA;
    address public tokenB;

    uint256 public reserveA;
    uint256 public reserveB;

    event Swap(address user, address tokenIn, uint256 amountIn, uint256 amountOut);
    event AddLiquidity(uint256 addA, uint256 addB);

    constructor(address _tokenA, address _tokenB) {
        tokenA = _tokenA;
        tokenB = _tokenB;
    }

    
    function addLiquidity(uint256 amountA, uint256 amountB)
        external
        onlyRole(ADMIN)
    {
        tokenA.safeTransferERC20(address(this), amountA);
        tokenB.safeTransferERC20(address(this), amountB);

        reserveA += amountA;
        reserveB += amountB;

        emit AddLiquidity(amountA, amountB);
    }

    
    function swap(address tokenIn, uint256 amountIn) external {
        require(tokenIn == tokenA || tokenIn == tokenB, "Invalid token");

        address tokenOut = tokenIn == tokenA ? tokenB : tokenA;

        uint256 reserveIn = tokenIn == tokenA ? reserveA : reserveB;
        uint256 reserveOut = tokenOut == tokenA ? reserveA : reserveB;

        tokenIn.safeTransferERC20(address(this), amountIn);

        uint256 amountOut = (reserveOut * amountIn) / (reserveIn + amountIn);

        tokenOut.safeTransferERC20(msg.sender, amountOut);

        if (tokenIn == tokenA) {
            reserveA += amountIn;
            reserveB -= amountOut;
        } else {
            reserveB += amountIn;
            reserveA -= amountOut;
        }

        emit Swap(msg.sender, tokenIn, amountIn, amountOut);
    }
}