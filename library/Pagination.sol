// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

library Pagination {


    function getPageBounds(
        uint256 totalLength,
        uint256 page,
        uint256 perPage
    ) internal pure returns (uint256 start, uint256 end) {
        require(page > 0, "Page must start from 1");

        if (totalLength == 0) return (0, 0);

        start = (page - 1) * perPage;
        if (start >= totalLength) return (totalLength, totalLength);

        end = start + perPage;
        if (end > totalLength) end = totalLength;
    }
}