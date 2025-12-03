// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

contract RoleControl {
    mapping(bytes32 => mapping(address => bool)) private _roles;

    bytes32 public constant ADMIN = keccak256("ADMIN");
    bytes32 public constant OPERATOR = keccak256("OPERATOR");

    event RoleGranted(bytes32 role, address account);
    event RoleRevoked(bytes32 role, address account);

    modifier onlyRole(bytes32 role) {
        require(_roles[role][msg.sender], "Not authorized");
        _;
    }

    constructor() {
        _grantRole(ADMIN, msg.sender);
    }

    function grantRole(bytes32 role, address account) external onlyRole(ADMIN) {
        _grantRole(role, account);
    }

    function revokeRole(bytes32 role, address account) external onlyRole(ADMIN) {
        _roles[role][account] = false;
        emit RoleRevoked(role, account);
    }

    function hasRole(bytes32 role, address account) public view returns (bool) {
        return _roles[role][account];
    }

    function _grantRole(bytes32 role, address account) internal {
        _roles[role][account] = true;
        emit RoleGranted(role, account);
    }
}