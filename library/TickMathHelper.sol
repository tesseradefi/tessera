// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

library TickMathHelper {
    int24 internal constant MIN_TICK = -887272;
    int24 internal constant MAX_TICK =  887272;

    function getFullRange(int24 poolFee) internal pure returns (int24 tickLower, int24 tickUpper) {
        int24 tickSpacing = getTickSpacing(poolFee);

        tickLower = (MIN_TICK / tickSpacing) * tickSpacing;
        if (tickLower < MIN_TICK) {
            tickLower += tickSpacing;
        }

        tickUpper = (MAX_TICK / tickSpacing) * tickSpacing;
        if (tickUpper > MAX_TICK) {
            tickUpper -= tickSpacing;
        }
    }

    function getTickSpacing(int24 poolFee) internal pure returns (int24) {
        if (poolFee == 100) return 1;       
        if (poolFee == 500) return 10;      
        if (poolFee == 3000) return 60;     
        if (poolFee == 10000) return 200;   
        revert("Unsupported fee tier");
    }

    function floorToSpacing(int24 tick, int24 spacing) internal pure returns (int24) {
        return (tick / spacing) * spacing;
    }
}