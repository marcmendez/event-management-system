pragma solidity ^0.4.2;

import "./Auth.sol";

contract AuthStoppable is Auth {
    bool public emergency;

    modifier stopInEmergency {
        require(!emergency);
        _;
    }

    function startEmergency() external onlyAdminOrMerchant {
        emergency = true;
    }

    function stopEmergency() external onlyAdminOrMerchant {
        emergency = false;
    }

    function init(address theMerchant, address permissionManagerAddress) internal {
        super.init(theMerchant, permissionManagerAddress);
    }
}
