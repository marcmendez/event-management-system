pragma solidity ^0.4.18;

import "./Ownable.sol";
import "./TicketToken.sol";

contract EventData is Ownable {

    address[] logics;

    enum EventStatus {Pending, Accepted, Opened, OnGoing, Finished, Success, Failed, Frozen, Cancelled}
    enum OrganizerStatus {Pending, Accepted, Success, Failed}

    /* Event Information */
    uint public id;             /* id: identifier of the event (Theorically physical db related) */
    uint public date;           /* date: celebration date of the event */
    uint public duration;       /* duration: duration of the given event */
    EventStatus public eventStatus;

    /* Organizers Information */
    address[] public organizers;                                       /* organizers: adresses of the organizers */
    mapping (address => OrganizerInfo) public organizersInfo;   /* organizersInfo: information of the organizers */

    struct OrganizerInfo {
        OrganizerStatus status;         /* status: status of the organizer */
        uint16 percentage;              /* percentage: percentage of earnings he is given */
    }

    /* Tickets */
    address[] tickets;              /* tickets: collection of all the tickets for a concert */

    uint16 redButton = 0;           /* redButton: count of redButton votes */
    uint totalTickets = 0;          /* totalTickets: count of totalTicketsAssigned */

    function EventData (uint _id, address _organizer, uint16 _percentage) public Ownable(msg.sender) {
        id = _id;
        organizers.push(_organizer);
        organizersInfo[_organizer] = OrganizerInfo(OrganizerStatus(0),_percentage);
    }

    function getId() public constant returns (uint) {
        return id;
    }

    function getDate() public constant returns (uint) {
        return date;
    }

    function setDate(uint _date) public onlyOwner {
        date = _date;
    }

    function getDuration() public constant returns (uint) {
       return duration;
    }

    function setDuration(uint _duration) public onlyOwner {
       duration = _duration;
    }

    function getEventStatus() public constant returns (uint8) {
        return uint8(eventStatus);
    }

    function setEventStatus(uint8 _eventStatus) public onlyOwner {
        eventStatus = EventStatus(_eventStatus);
    }

    function getNumberOrganizers() public constant returns (uint) {
        return organizers.length;
    }

    function getOrganizerAt(uint i) public constant returns (address) {
        return (organizers[i]);
    }

    function getOrganizerInfo(address _organizer) public constant returns (uint8, uint16) {
        return (uint8(organizersInfo[_organizer].status), organizersInfo[_organizer].percentage);
    }

    function addOrganizer(address _organizer, uint16 _percentage) public {
        organizers.push(_organizer);
        organizersInfo[_organizer] = OrganizerInfo(OrganizerStatus(0), _percentage);
    }

    function setOrganizerInfo(address _organizer, uint8 _status, uint16 _percentage) public {
        organizersInfo[_organizer] = OrganizerInfo(OrganizerStatus(_status), _percentage);
    }

    function getNumberTickets() public constant returns (uint) {
        return tickets.length;
    }

    function getTicketAt(uint i) public constant returns (address) {
        return tickets[i];
    }

    function addTicket(address _ticket) public {
        tickets.push(_ticket);
    }

    function getTotalTickets() public constant returns (uint) {
        return totalTickets;
    }

    function addRedButton(uint16 _value) public {
        redButton += _value;
    }

    function addTotalTickets(uint16 _value) public {
        totalTickets += _value;
    }

    function getRedButtonCount() public constant returns (uint16) {
        return redButton;
    }


}