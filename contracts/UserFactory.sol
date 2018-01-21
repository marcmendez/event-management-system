pragma solidity ^0.4.18;

import "./BasicUser.sol";
import "./Organizer.sol";

contract UserFactory is Ownable {

  address bsToken;
  address eventFactory;
  address[] organizers;
  address[] users;
  event OrganizerCreated(uint identifier, address _organizer);
  event BasicUserCreated(uint identifier, address _user);

  mapping(address => bool) usedAddresses;

  function UserFactory(address _BSTokenFrontend, address _EventFactory) Ownable(msg.sender) public {
    bsToken = _BSTokenFrontend;
    eventFactory = _EventFactory;
  }

  function createBasicUser() public returns (address){
    require(!usedAddresses[msg.sender]);
    address basicUser = new BasicUser(msg.sender, bsToken);
    usedAddresses[msg.sender] = true;
    users.push(basicUser);
    BasicUserCreated(2, basicUser);
    return basicUser;

  }

  function createOrganizer() public returns (address){
    require(!usedAddresses[msg.sender]);
    address organizer = new Organizer(msg.sender, bsToken, eventFactory);
    usedAddresses[msg.sender] = true;
    organizers.push(organizer);
    OrganizerCreated(1, organizer);
    return organizer;

  }

  function getBasicUserAt(uint i) public constant returns (address) {
    return users[i];
  }

  function getOrganizer(uint i) public constant returns (address) {
    return organizers[i];
  }

}
