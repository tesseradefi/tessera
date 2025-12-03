// SPDX-License-Identifier: MIT


pragma solidity ^0.8.20;

import {ERC721} from "../ERC721.sol";
import {Context} from "../../../utils/Context.sol";


abstract contract ERC721Burnable is Context, ERC721 {
    
    function burn(uint256 tokenId) public virtual {
        
        
        _update(address(0), tokenId, _msgSender());
    }
}
