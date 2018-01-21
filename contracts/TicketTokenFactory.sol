pragma solidity ^0.4.18;

import "./Ownable.sol";
import "./TicketToken.sol";

/**
 * @title TicketTokenFactory
 * @dev Factory for the ticketToken class, allows events to create different
 *      types of tickets.
 */

contract TicketTokenFactory is Ownable {

    address[] public tickets;
    event TicketCreated(uint identifier, address _ticketToken, address _event);

    /**
     * @dev Creates the factory, it must be created just once by the admin of the system.
     */

    function TicketTokenFactory () public Ownable(msg.sender) {

    }

    /**
     * @dev Creates and instantiates a TicketToken
     * @param _ticketType is the identifier of the type.
     * @param _price is the value of the ticket.
     * @param _quantity is the amount of tickets to create.
     * - The admin of the TicketToken is going to be the msg sender.
     */

    function createTicketToken(uint8 _ticketType, uint16 _price, uint16 _quantity) public returns (address) {
        address ticketToken = new TicketToken(msg.sender, _quantity, _price, _ticketType);
        tickets.push(ticketToken);
        TicketCreated(1, ticketToken, msg.sender);
        return ticketToken;
    }

}
