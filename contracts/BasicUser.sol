pragma solidity ^0.4.0;

import "./User.sol";
import "./TicketToken.sol";
import "./Event.sol";

contract BasicUser is User{
    address[] public tickets;

    function BasicUser(address _owner, address _BSTokenFrontend) User(_BSTokenFrontend, _owner) public {

    }

    function buyTicket(address _event, uint8 ticketType, uint8 _amount) public {
        TicketToken ticketToken = TicketToken(Event(_event).getTicket(ticketType));
        uint256 totalPrice = ticketToken.getValue() * _amount;

        BSTokenFrontend(_BSTokenFrontend).approve(_event, totalPrice); 
        Event(_event).buyTickets(ticketType, _amount);
        if (!containsElement(address(ticketToken))) tickets.push(address(ticketToken));
    }

    // This has to be called when Event raise a resell ticket event
    function refundTicketToken(address _event, address _ticketToken, uint16 _amount) public {
        uint256 totalPrice = TicketToken(_ticketToken).getValue() * _amount;
        BSTokenFrontend(_BSTokenFrontend).transferFrom(_event, this, totalPrice);
    }

    function resellTicket(address _ticket, uint16 _amount) public {
        TicketToken(_ticket).approve(_amount);
    }

    function useTicket(address _ticket) public {
        TicketToken(_ticket).useTicket(1);
    }

    function redButton(address _event) public {
        Event(_event).redButton();
    }

    function containsElement(address element) internal returns(bool found) {
        for (uint i = 0; i < tickets.length; i++) {
            if (tickets[i] == element) return true;
        }
        return false;
    }

    
}