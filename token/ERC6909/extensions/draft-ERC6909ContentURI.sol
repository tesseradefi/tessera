// SPDX-License-Identifier: MIT


pragma solidity ^0.8.20;

import {ERC6909} from "../draft-ERC6909.sol";
import {IERC6909ContentURI} from "../../../interfaces/draft-IERC6909.sol";


contract ERC6909ContentURI is ERC6909, IERC6909ContentURI {
    string private _contractURI;
    mapping(uint256 id => string) private _tokenURIs;

    
    event ContractURIUpdated();

    
    event URI(string value, uint256 indexed id);

    
    function contractURI() public view virtual override returns (string memory) {
        return _contractURI;
    }

    
    function tokenURI(uint256 id) public view virtual override returns (string memory) {
        return _tokenURIs[id];
    }

    
    function _setContractURI(string memory newContractURI) internal virtual {
        _contractURI = newContractURI;

        emit ContractURIUpdated();
    }

    
    function _setTokenURI(uint256 id, string memory newTokenURI) internal virtual {
        _tokenURIs[id] = newTokenURI;

        emit URI(newTokenURI, id);
    }
}
