pragma solidity ^0.4.18;

/**
 * @title ERC20
 * @dev Token Standard (Transferable Fungibles)
 * @dev see https://github.com/ethereum/eips/issues/20
 */

 contract ERC20 {

    function balanceOf(address _owner) public constant returns (uint16 balance);
    function transfer(address _to, uint16 _value) public returns (bool) ;
    function transferFrom(address _from, address _to, uint16 _value) public returns (bool success);
    function approve(uint16 _value) public returns (bool);
    function allowance(address _owner) public view returns (uint256);

}
