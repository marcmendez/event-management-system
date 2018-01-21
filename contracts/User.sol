pragma solidity ^0.4.0;

import "./Ownable.sol";

contract User is Ownable{
    address internal _BSTokenFrontend;

    function User(address _bsTokenFrontend, address _owner) public Ownable(_owner) {
        _BSTokenFrontend = _bsTokenFrontend;
    }
}