// SPDX-License-Identifier: MIT
pragma solidity 0.8.6;

import {ArbSys} from "../vendor/@arbitrum/nitro-contracts/src/precompiles/ArbSys.sol";
import {ArbGasInfo} from "../vendor/@arbitrum/nitro-contracts/src/precompiles/ArbGasInfo.sol";
import {OVM_GasPriceOracle} from "../vendor/@eth-optimism/contracts/v0.8.6/contracts/L2/predeploys/OVM_GasPriceOracle.sol";




library ChainSpecificUtil {
  

  
  
  address private constant ARBSYS_ADDR = address(0x0000000000000000000000000000000000000064);
  ArbSys private constant ARBSYS = ArbSys(ARBSYS_ADDR);

  
  
  address private constant ARBGAS_ADDR = address(0x000000000000000000000000000000000000006C);
  ArbGasInfo private constant ARBGAS = ArbGasInfo(ARBGAS_ADDR);

  uint256 private constant ARB_MAINNET_CHAIN_ID = 42161;
  uint256 private constant ARB_GOERLI_TESTNET_CHAIN_ID = 421613;
  uint256 private constant ARB_SEPOLIA_TESTNET_CHAIN_ID = 421614;

  

  
  
  bytes internal constant L1_FEE_DATA_PADDING =
    "0xffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff";
  
  
  address private constant OVM_GASPRICEORACLE_ADDR = address(0x420000000000000000000000000000000000000F);
  OVM_GasPriceOracle private constant OVM_GASPRICEORACLE = OVM_GasPriceOracle(OVM_GASPRICEORACLE_ADDR);

  uint256 private constant OP_MAINNET_CHAIN_ID = 10;
  uint256 private constant OP_GOERLI_CHAIN_ID = 420;
  uint256 private constant OP_SEPOLIA_CHAIN_ID = 11155420;

  
  uint256 private constant BASE_MAINNET_CHAIN_ID = 8453;
  uint256 private constant BASE_GOERLI_CHAIN_ID = 84531;
  uint256 private constant BASE_SEPOLIA_CHAIN_ID = 84532;

  

  
  function _getBlockhash(uint64 blockNumber) internal view returns (bytes32) {
    uint256 chainid = block.chainid;
    if (_isArbitrumChainId(chainid)) {
      if ((_getBlockNumber() - blockNumber) > 256 || blockNumber >= _getBlockNumber()) {
        return "";
      }
      return ARBSYS.arbBlockHash(blockNumber);
    }
    return blockhash(blockNumber);
  }

  
  function _getBlockNumber() internal view returns (uint256) {
    uint256 chainid = block.chainid;
    if (_isArbitrumChainId(chainid)) {
      return ARBSYS.arbBlockNumber();
    }
    return block.number;
  }

  
  function _getCurrentTxL1GasFees(bytes memory txCallData) internal view returns (uint256) {
    uint256 chainid = block.chainid;
    if (_isArbitrumChainId(chainid)) {
      return ARBGAS.getCurrentTxL1GasFees();
    } else if (_isOptimismChainId(chainid)) {
      return OVM_GASPRICEORACLE.getL1Fee(bytes.concat(txCallData, L1_FEE_DATA_PADDING));
    }
    return 0;
  }

  
  function _getL1CalldataGasCost(uint256 calldataSizeBytes) internal view returns (uint256) {
    uint256 chainid = block.chainid;
    if (_isArbitrumChainId(chainid)) {
      (, uint256 l1PricePerByte, , , , ) = ARBGAS.getPricesInWei();
      
      
      return l1PricePerByte * (calldataSizeBytes + 140);
    } else if (_isOptimismChainId(chainid)) {
      return _calculateOptimismL1DataFee(calldataSizeBytes);
    }
    return 0;
  }

  
  function _isArbitrumChainId(uint256 chainId) internal pure returns (bool) {
    return
      chainId == ARB_MAINNET_CHAIN_ID ||
      chainId == ARB_GOERLI_TESTNET_CHAIN_ID ||
      chainId == ARB_SEPOLIA_TESTNET_CHAIN_ID;
  }

  
  function _isOptimismChainId(uint256 chainId) internal pure returns (bool) {
    return
      chainId == OP_MAINNET_CHAIN_ID ||
      chainId == OP_GOERLI_CHAIN_ID ||
      chainId == OP_SEPOLIA_CHAIN_ID ||
      chainId == BASE_MAINNET_CHAIN_ID ||
      chainId == BASE_GOERLI_CHAIN_ID ||
      chainId == BASE_SEPOLIA_CHAIN_ID;
  }

  function _calculateOptimismL1DataFee(uint256 calldataSizeBytes) internal view returns (uint256) {
    
    
    
    
    uint256 l1BaseFeeWei = OVM_GASPRICEORACLE.l1BaseFee();
    uint256 numZeroBytes = 0;
    uint256 numNonzeroBytes = calldataSizeBytes - numZeroBytes;
    uint256 txDataGas = numZeroBytes * 4 + numNonzeroBytes * 16;
    uint256 fixedOverhead = OVM_GASPRICEORACLE.overhead();

    
    
    
    
    uint256 scalar = OVM_GASPRICEORACLE.scalar();
    uint256 scalarDecimals = OVM_GASPRICEORACLE.decimals();
    uint256 divisor = 10 ** scalarDecimals;

    uint256 l1DataFee = (l1BaseFeeWei * (txDataGas + fixedOverhead) * scalar) / divisor;
    return l1DataFee;
  }
}
