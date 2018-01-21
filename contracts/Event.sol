pragma solidity ^0.4.18;

import "./Ownable.sol";
import "./TicketToken.sol";
import "./TicketTokenFactory.sol";
import "./EventData.sol";
import "./BSTokenFrontend.sol";

contract Event is Pausable {

    EventData data;
    address factory;
    address bsToken;

    event OrganizerAdded(uint identifier, address _newOrganizer, address _addedBy);
    event OrganizerAccepted(uint identifier, address _organizer);
    event OrganizerCancelled(uint identifier, address _organizer);
    event EventStatusChanged(uint identifier, uint _newStatus, uint _oldStatus, address _changedBy);
    event RedButton(uint identifier, uint _amount, address _pressedBy);

    
    function Event(address _owner, address _organizer, uint16 _percentage, uint _id, address _bsToken, address _ticketTokenFactory) Ownable(_owner) public {
        data = new EventData(_id, _organizer, _percentage);
        bsToken = _bsToken;
        factory = _ticketTokenFactory;
    }
    
    function setFactory(address _factory) {
        factory = _factory;
    }
    
    function setBsToken(address _bsToken) {
        bsToken = _bsToken;
    }

    function getOrganizerAt(uint16 i) public constant returns (address) {
        return data.getOrganizerAt(i);
    }

    function getStatus() public constant returns (uint16) {
        return data.getEventStatus();
    }

    /**
     * @dev Initializes the date and the duration of the event.
     * - onlySubowner It can only be accessed by Organizers, Owners and the contract itself.
     * - onlyWhen only accessible when event is "Status.Pending"
     * @param _date date of the event.
     * @param _duration duration of the event.
     */

    function initializeDate(uint _date, uint _duration) public onlyOrganizer onlyWhen(0) whenNotPaused {
        data.setDate(_date);
        data.setDuration(_duration);
    }

    /**
     * @dev Adds an organizer to the event (organizerStatus=>Pending).
     * - onlySubowner It can only be accessed by Organizers, Owners and the contract itself.
     * - onlyWhen only accessible when event is "Status.Pending"
     * @param _organizerAddress is the identifier of the organizer to add.
     * @param _percentage is the percentage of money a organizer will recive of the total benefit.
     */

    function addOrganizer(address _organizerAddress, uint16 _percentage) public onlyOrganizer onlyWhen(0) whenNotPaused {
        data.addOrganizer(_organizerAddress, _percentage);
        OrganizerAdded(1, _organizerAddress, msg.sender);
    }

    /**
     * @dev Adds a ticketType to the event.
     * - onlySubowner It can only be accessed by Organizers, Owners and the contract itself.
     * - onlyWhen only accessible when event is "Status.Pending"
     * @param _ticketType is the identifier of the type.
     * @param _price is the value of the ticket.
     * @param _quantity is the amount of tickets to create.
     */

    function addTicket(uint8 _ticketType, uint16 _price, uint16 _quantity) public onlyOrganizer onlyWhen(0) whenNotPaused {
       data.addTicket(TicketTokenFactory(factory).createTicketToken(_ticketType,_price,_quantity));
    }

    /**
     * @dev Gets the count of ticket types of the event.
     * @return the amount of types of the event.
     */

    function getAmountTicketTypes() public constant returns (uint) {
        return data.getNumberTickets();
    }

    /**
     * @dev Gets the ticket of type i.
     * @return the address of the ticketToken of type (i) of the event.
     */

    function getTicket(uint16 i) public constant returns (address ticketToken) {
        return data.getTicketAt(i);
    }

    /**
     * @dev Assings the msg.sender a certain amount of tickets and transfers the amount of
     *      bs-tokens required to the event.
     * - onlyWhen only accessible when event is "Status.Accepted".
     * - The user must have allowed Event to withdraw the amount of money required.
     */

    function buyTickets(uint8 ticketType, uint8 amount) public onlyWhen(1) whenNotPaused {
        BSTokenFrontend(bsToken).transferFrom(msg.sender, this, TicketToken(data.getTicketAt(ticketType)).getValue() * amount);
        TicketToken(data.getTicketAt(ticketType)).assignTickets(msg.sender, amount);
        data.addTotalTickets(amount);
    }

    /**
     * @dev Allows the previous to refund the money of a resell.
     * - onlyOwner only accesible by the tickets.
     */

    function refundAResell(address _to, uint16 _quantity, uint8 ticketType) public onlyTicket whenNotPaused {
        BSTokenFrontend(bsToken).approve(_to, TicketToken(data.getTicketAt(ticketType)).getValue() * _quantity);
    }

    /**
     * @dev Allows the organizer(msg.sender) to accept the event conditions.
     * - onlySubowner It can only be accessed by subowners
     * - onlyWhen only accessible when event is "Status.Pending"
     * - only accessible when the organizer status is "Status.Pending"
     */

    function accept() public onlyOrganizer onlyWhen(0) whenNotPaused {
        var (organizerStatus, percentage) = data.getOrganizerInfo(msg.sender);
        require(organizerStatus == 0);
        data.setOrganizerInfo(msg.sender, 1, percentage);

        if (organizersMatch(1)) data.setEventStatus(1);
        OrganizerAccepted(2,msg.sender);
    }

     /**
     * @dev Allows the organizer(msg.sender) to cancel the event. It also auto-activate the refund.
     * - onlySubowner It can only be accessed by subowners
     * - onlyWhenRange only accessible when event is "Status.Pending" or "Status.Accepted"
     */

    function cancel() public onlyOrganizer onlyWhenRange([0, 1]) whenNotPaused {
        data.setEventStatus(8);
        OrganizerCancelled(3,msg.sender);
        activeRefund();
    }

    /**
     * @dev Allows the organizer(msg.sender) to open the event.
     * - onlySubowner It can only be accessed by subowners
     * - onlyWhen only accessible when event is "Status.Accepted"
     */


    function open() public onlyOrganizer onlyWhen(1) whenNotPaused {
        EventStatusChanged(4, 2, 1, msg.sender);
        data.setEventStatus(2);
    }

    /**
     * @dev Allows the organizer(msg.sender) to cancel the event. It also auto-activate the refund.
     * - onlySubowner It can only be accessed by subowners
     * - onlyWhenRange only accessible when event is "Status.Accepted" or "Status.Opened"
     */

    function start() public onlyOwner onlyWhenRange([1,2]) whenNotPaused {
        EventStatusChanged(4, 3, data.getEventStatus(), msg.sender);
        data.setEventStatus(3);
    }

    /**
     * @dev Allows the user(msg.sender) to complain.
     * - onlyWhenRange only accessible when event is "Status.OnGoing" or "Status.Finished"
     */

    function redButton() public onlyWhenRange([3,4]) {
        uint16 redButtonCount = 0;
        for (uint8 i = 0; i < data.getNumberTickets(); i++) {
            redButtonCount += TicketToken(data.getTicketAt(i)).redButton(msg.sender);
        }
        data.addRedButton(redButtonCount);
        RedButton(5,redButtonCount, msg.sender);
    }

    /**
     * @dev Allows the owner(artistic island) to end the event.
     * - onlyOwner It can only be accessed by the Owner.
     * - onlyWhen only accessible when event is "Status.OnGoing".
     */

    function end() public onlyOwner onlyWhen(3) whenNotPaused {
        EventStatusChanged(4, 4, 3, msg.sender);
        data.setEventStatus(4);
    }

    /**
     * @dev Allows the organizers (msg.senders) to evaluate the event.
     * - onlySubowners It can only be accessed by the subowners/organizers.
     * - onlyWhen only accessible when event is "Status.Finished".
     */

    function evaluate(bool eventSuccess) public onlyOrganizer onlyWhen(4) {
        var (, percentage) = data.getOrganizerInfo(msg.sender);
        if (eventSuccess) data.setOrganizerInfo(msg.sender, 2, percentage);
        else data.setOrganizerInfo(msg.sender, 3, percentage);
    }

    /**
     * @dev Allows the owner(artistic island) to reslove the evaluations of the event.
     * - onlyOwner It can only be accessed by the Owner.
     * - onlyWhen only accessible when event is "Status.Finished".
     */

    function resolveEvaluation() public onlyOwner onlyWhen(4) {
        bool organizersEvaluationSuccess = organizersMatch(2);
        bool organizersEvaluationFailed = organizersMatch(3);
        bool clientsEvaluation = (data.getRedButtonCount() < data.getTotalTickets()/4);
        if (organizersEvaluationFailed) { data.setEventStatus(6); activeRefund(); }
        else if (organizersEvaluationSuccess && clientsEvaluation) { data.setEventStatus(5); activePayment(); }
        else data.setEventStatus(7);
        pauseTickets();
        EventStatusChanged(4, data.getEventStatus(), 4, msg.sender);
    }

    /**
     * @dev Allows the owner(artistic island) to reslove the evaluations of the event.
     * - onlyOwner It can only be accessed by the Owner.
     * - onlyWhen only accessible when event is "Status.Frozen".
     */

    function resolveFrozen(bool success) public onlyOwner onlyWhen(7) {
        if (success) { data.setEventStatus(5); activePayment();  }
        else { data.setEventStatus(6); activeRefund(); }

        EventStatusChanged(4, data.getEventStatus(), 7, msg.sender);
    }

    modifier onlyWhen(uint8 evStatus) {
        require(data.getEventStatus() == evStatus);
        _;
    }

    modifier onlyWhenRange(uint8 [2] evStatus) {
        bool found = false;
        for(uint8 i = 0; i < evStatus.length; i++) {
            found = (evStatus[i] == data.getEventStatus());
            if (found) break;
        }
        require(found);
        _;
    }


    modifier onlyTicket() {
        bool found = false;
        for(uint8 i = 0; i < data.getNumberTickets(); i++) {
            found = (data.getTicketAt(i) == msg.sender);
            if (found) break;
        }
        require(found);
        _;
    }

    modifier onlyOrganizer() {
        bool found = false;
        for (uint i = 0; i < data.getNumberOrganizers(); i++) {
            found = (data.getOrganizerAt(i) == msg.sender);
            if (found) break;
        }
        require(found);
        _;
    }

    function organizersMatch(uint8 status) internal constant returns (bool) {
        for (uint i = 0; i < data.getNumberOrganizers(); i++) {
            var (organizerStatus,) = data.getOrganizerInfo(data.getOrganizerAt(i));
            if (organizerStatus != status) return false;
        }
        return true;
    }

    function activePayment() internal onlyWhen(5) whenNotPaused {
        
        for (uint i = 0; i < data.getNumberOrganizers(); ++i) {
            var (, aux) = data.getOrganizerInfo(data.getOrganizerAt(i));
            BSTokenFrontend(bsToken).approve(data.getOrganizerAt(i), aux * BSTokenFrontend(bsToken).balanceOf(this));
        }
    
    }

    function activeRefund() internal whenNotPaused {
        require(data.getEventStatus() == 6 || data.getEventStatus() == 8);
        for (uint i = 0; i < data.getNumberTickets(); ++i) {
          for (uint j = 0; j < TicketToken(data.getTicketAt(i)).getNumberClients(); ++j) {
            BSTokenFrontend(bsToken).approve(TicketToken(data.getTicketAt(i)).getClientAt(j), TicketToken(data.getTicketAt(i)).getValue() * TicketToken(data.getTicketAt(i)).balanceOf(TicketToken(data.getTicketAt(i)).getClientAt(j)));
          }
        }
        /* foreach ticket, foreach client: allowance (this, clientaddress, value*balance); */
    }

    function pauseTickets() internal  {
        for(uint8 i = 0; i < data.getNumberTickets(); i++) (TicketToken(data.getTicketAt(i)).pause());
    }

}