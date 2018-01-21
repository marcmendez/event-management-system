pragma solidity ^0.4.2;

import "./PermissionManager.sol";

contract Admin {
    PermissionManager pm;

    modifier onlyAdmin {
        require(pm.getNetworkAdmin(pm.getRol(msg.sender)));
        _;
    }

    function init(address permissionManagerAddress) internal {
        pm = PermissionManager(permissionManagerAddress);
    }
}