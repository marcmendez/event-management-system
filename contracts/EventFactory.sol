pragma solidity ^0.4.18;

import "./Event.sol";

contract EventFactory is Ownable {

  address[] events;
  address public ticketTokenFactory;
  address public bsToken;

  event CreateEvent(uint idEv, address _event, address _createdBy);

  /**
   * @dev Creates the factory, it must be created just once by the admin of the system.
   */

  function EventFactory (address _ticketTokenFactory , address _bsTokenFrontend) public payable Ownable(msg.sender) {
      ticketTokenFactory = _ticketTokenFactory;
      bsToken = _bsTokenFrontend;
  }

  /**
   * @dev Creates and instantiates a Event.
   * @param _organizer is the first organizer of the event (the one creating it).
   * @param _percentage is the percentage the organizer expect to receive.
   * @param _id is the id of the event.
   */

  function createEvent(address _organizer, uint16 _percentage, uint _id) public returns (address) {
      address _event = new Event(owner, _organizer, _percentage, _id, bsToken, ticketTokenFactory);
      events.push(_event);
      CreateEvent(1, _event, _organizer);
      return _event;
  }

  function getEventAt(uint i) constant returns (address) {
    return events[i];
  }

}
