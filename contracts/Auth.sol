pragma solidity ^0.4.2;

import "./PermissionManager.sol";

contract Auth {
    PermissionManager pm;
    address public merchant;

    modifier onlyAdminOrMerchant {
        require (pm.getNetworkAdmin(pm.getRol(msg.sender)) || msg.sender == merchant);
        _;
    }

    modifier onlyAdmin {
        require(pm.getNetworkAdmin(pm.getRol(msg.sender))) ;
        _;
    }

    function init(address theMerchant, address permissionManagerAddress) internal {
        merchant = theMerchant;
        pm = PermissionManager(permissionManagerAddress);
    }
}
