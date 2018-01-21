pragma solidity ^0.4.18;

import "./Ownable.sol";

contract TicketTokenData is Ownable {

     /* TicketToken basic information (constant) */
     uint16 public value;                   /* value: the price of each ticket. */
     uint8 public ticketType;               /* ticketType: the type of ticket. */
     uint16 public cap;                     /* cap: maximum number of tickets. */

     /* State variables (variable) */
     uint16 public totalSupply = 0;             /* totalSupply: number of tickets sold. */
     uint16 public totalResell = 0;             /* totalResell: number of tickets to resell. */

     mapping(address => uint16) balances;                   /* balances: (who, available tickets) */
     mapping (address => uint16) internal used;             /* used: (who, used tickets) */
     mapping (address => uint16) internal redButton;        /* used: (who, used tickets) */
     mapping (address => uint16) internal allowed;          /* allowed: (who, resalable tickets) */

     address[] internal clusterAllowedIndex;                /* Auxiliar to store the "Resellers" */

     address[] internal clusterClient;                /* Auxiliar to store the "Clients" */


     function TicketTokenData(uint16 _cap, uint16 _value, uint8 _type) public Ownable (msg.sender) {
        value = _value;
        cap = _cap;
        ticketType = _type;
     }

    function getCap() public constant returns (uint16) {
        return cap;
    }

    function getType() public constant returns (uint8) {
         return ticketType;
     }

     function getValue() public constant returns (uint16) {
         return value;
     }

     function getTotalSupply() public constant returns (uint16) {
         return totalSupply;
     }

     function setTotalSupply(uint16 _number) public onlyOwner {
         totalSupply=_number;
     }

     function getTotalResell() public constant returns (uint16) {
         return totalResell;
     }

     function setTotalResell(uint16 _number) public onlyOwner {
         totalResell=_number;
     }

     function getBalance(address _addr) public constant returns (uint16) {
        return balances[_addr];
     }

     function setBalance(address _addr, uint16 _balance) public onlyOwner {
        balances[_addr] = _balance;
     }

     function getUsed(address _addr) public constant returns (uint16) {
        return used[_addr];
     }

     function setUsed(address addr, uint16 _quantity) public onlyOwner {
        used[addr] = _quantity;
     }

     function getRedButton(address _addr) public constant returns (uint16) {
        return redButton[_addr];
     }

     function setRedButton(address addr, uint16 _quantity) public onlyOwner {
        redButton[addr] = _quantity;
     }

     function getAllowed(address _addr) public constant returns (uint16) {
        return used[_addr];
     }

     function setAllowed(address _addr, uint16 _quantity) public onlyOwner {
        used[_addr] = _quantity;
     }

     function getAllowedClusterSize() public constant returns (uint) {
        return clusterAllowedIndex.length;
     }

     function getAllowedIndexAt (uint16 i) public constant returns (address){
        return clusterAllowedIndex[i];
     }

     function setAllowedIndex (address _addr) public onlyOwner {
        clusterAllowedIndex.push(_addr);
     }

     function deleteAllowedIndexAt (uint16 i) public onlyOwner {
         delete clusterAllowedIndex[i];
     }

     function getNumberClients() constant returns (uint) {
        return clusterClient.length;
     }

     function getClientAt(uint i) constant returns (address) {
        return clusterClient[i];
     }

     function setClient(address _client) public onlyOwner {
        clusterClient.push(_client);
     }

}