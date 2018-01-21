pragma solidity ^0.4.0;

import "./User.sol";
import "./TicketToken.sol";
import "./Event.sol";
import "./EventFactory.sol";

contract Organizer is User {

    address[] public events;
    address eventFactory;

    function Organizer(address _owner,address _BSTokenFrontends , address _eventFactory) User (_BSTokenFrontends, _owner) {
      eventFactory = _eventFactory;
    }

    function createEvent(uint16 _percentage, uint _id) public onlyOwner {
        events.push(EventFactory(eventFactory).createEvent(address(this), _percentage, _id));
    }

    function setDate(address _event, uint _date, uint _duration) public onlyOwner {
        Event(_event).initializeDate(_date, _duration);
    }

    function addOrganizer(address _event, address _organizer, uint16 _percentage) public onlyOwner {
        Event(_event).addOrganizer(_organizer, _percentage);
    }

    function addTicket(address _event, uint8 _ticketType, uint16 _price, uint16 _quantity) public onlyOwner {
        Event(_event).addTicket(_ticketType, _price, _quantity);
    }

    function acceptEvent(address _event) public onlyOwner {
        Event(_event).accept();
    }

    function openEvent(address _event) public onlyOwner {
        Event(_event).open();
    }

    function cancelEvent(address _event) public onlyOwner {
        Event(_event).cancel();
    }

    function evaluate(address _event, bool success) public onlyOwner {
        Event(_event).evaluate(success);
    }

    // Has to be called when payment ready
    function getPayment(address _event, uint256 _amount) public onlyOwner {
        BSTokenFrontend(_BSTokenFrontend).transferFrom(Event(_event), address(this), _amount);
    }

}
