// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

library StringArrLib {



    function removeAt(string[] memory arr, string memory _stakeId) internal pure returns (string[] memory) {
        string[] memory newArr = new string[](arr.length -1);
        uint j = 0;
        for(uint i = 0 ; i< arr.length ; i++){
            if(keccak256(bytes(arr[i])) == keccak256(bytes(_stakeId))){
                continue;
            }
            newArr[j] = arr[i];
            j++;            
        }
        return newArr;
    }

}