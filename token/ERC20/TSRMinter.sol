// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol";
import "@openzeppelin/contracts-upgradeable/access/OwnableUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/utils/ReentrancyGuardUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/access/AccessControlUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/utils/PausableUpgradeable.sol";
import "./interfaces/ITSR.sol";


contract TSRMinter is Initializable ,OwnableUpgradeable ,ReentrancyGuardUpgradeable,AccessControlUpgradeable,PausableUpgradeable{

    address public tsrAddress;

    bytes32 public constant MINTER_ROLE = keccak256("MINTER_ROLE");

	/**
	 * @dev admin role hash
	 */
	bytes32 public constant ADMIN_ROLE = keccak256("ADMIN_ROLE");

    event SetMinterEvent(address indexed minter , bool status ,uint256 timestamp);
    event SetTSRAddressEvent(address indexed tsrAddress , uint256 timestamp);
    event MintEvent(address indexed to , uint256 amount , uint256 timestamp);

    function initialize() public initializer {
        __Ownable_init(_msgSender());
        __ReentrancyGuard_init();
        __Pausable_init();

        _grantRole(DEFAULT_ADMIN_ROLE, msg.sender);
		_grantRole(MINTER_ROLE, msg.sender);
		_grantRole(ADMIN_ROLE, msg.sender);
    }

    constructor(){
        _disableInitializers();
    }

    function setTSRAddress(address _tsrAddress) external onlyRole(ADMIN_ROLE) {
        require(_tsrAddress != address(0), "Invalid TSR address");
        tsrAddress = _tsrAddress;
        emit SetTSRAddressEvent(_tsrAddress, block.timestamp);
    }

    function mint(address to, uint256 amount) external whenNotPaused onlyRole(MINTER_ROLE) nonReentrant{
        require(tsrAddress != address(0), "TSR address not set");
        require(to != address(0), "Invalid to address");
        require(amount > 0, "Amount must be greater than zero");
        ITSR(tsrAddress).mint(to, amount);
        emit MintEvent(to, amount, block.timestamp);
    }

    function stop() external onlyRole(ADMIN_ROLE) {
		// unpause core functions
		_pause();
	}

	function open() external onlyRole(ADMIN_ROLE) {
		// pause core functions
		_unpause();
	}

}