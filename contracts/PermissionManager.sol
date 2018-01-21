pragma solidity ^0.4.4;

contract PermissionManager {
  mapping(address => uint) public _rol; // Defines a specifid rol to an address. Default rol: 0
  uint public _numRols;

  // Which rol can perform the following actions

  mapping(uint => bool) public _networkAdmin; // Admins can do everything. Only 1 by default
  mapping(uint => bool) public _identityManager; // Create roles and assign identities
  mapping(uint => bool) public _reputationProvider; // Oracle to provide the reputation

  // Which interactions are allowed between 2 roles
  // Rol1 => Rol2 => Interaction => allowed?
  mapping(uint => mapping(uint => mapping(uint => bool))) public _relationships;

  event ev_Rol(uint indexed rol, address who);
  event ev_Interaction(uint indexed rolFrom, uint indexed rolTo, uint indexed value, bool allowed);
  event ev_Admin(uint indexed rol, bool allowed);
  event ev_IdentityManager(uint indexed rol, bool allowed);
  event ev_ReputationProvider(uint indexed rol, bool allowed);

  modifier rolInRange(uint rol) {
    require(rol < _numRols)
      ;
    _;
  }

  function isNetworkAdmin(address who) {
    require(_networkAdmin[_rol[who]])
      ;
  }

  function isIdentityManager(address who) {
    require(_networkAdmin[_rol[who]] && !_identityManager[_rol[who]])
      ;
  }

  function isReputationProvider(address who) {
    require(_networkAdmin[_rol[who]] && !_reputationProvider[_rol[who]])
      ;
  }

  function isInteractionAllowed(address from, address to, uint interaction) {
    require(_relationships[_rol[from]][_rol[to]][interaction])
      ;
  }

  function PermissionManager() {
    _rol[msg.sender] = 1;
    _networkAdmin[1] = true;
    _numRols = 2; // Default: 0 and Admin: 1
  }

  /**
   * Gives a rol to an ID
   * @param id ID
   */
  function createAndSetRol(address id) returns(uint) {
    isIdentityManager(msg.sender);

    _rol[id] = _numRols;
    _numRols++;

    ev_Rol(_rol[id], id);

    return _rol[id];
  }

  function createRol() returns(uint) {
    isIdentityManager(msg.sender);

    _numRols++;

    return _numRols-1;
  }

  /**
   * Gives a rol to an ID
   * @param id ID
   * @param rol Rol
   */
  function setRol(address id, uint rol) rolInRange(rol) {
    isIdentityManager(msg.sender);

    _rol[id] = rol;

    ev_Rol(rol, id);
  }

  /**
   * Removes a rol of an ID
   * @param id ID
   */
  function removeRol(address id) {
    isIdentityManager(msg.sender);

    setRol(id, 0);
  }

  function allowInteraction(uint rol1, uint rol2, uint interaction) {
    isIdentityManager(msg.sender);

    _relationships[rol1][rol2][interaction] = true;

    ev_Interaction(rol1, rol2, interaction, true);
  }

  function disallowInteraction(uint rol1, uint rol2, uint interaction) {
    isIdentityManager(msg.sender);

    _relationships[rol1][rol2][interaction] = false;

    ev_Interaction(rol1, rol2, interaction, false);
  }

  // Functions to manage roles permissions

  function addNetworkAdmin(uint rol) {
    isIdentityManager(msg.sender);

    _networkAdmin[rol] = true;

    ev_Admin(rol, true);
  }

  function addIdentityManager(uint rol) {
    isIdentityManager(msg.sender);

    _identityManager[rol] = true;

    ev_IdentityManager(rol, true);
  }

  function addReputationProvider(uint rol) {
    isIdentityManager(msg.sender);

    _reputationProvider[rol] = true;

    ev_ReputationProvider(rol, true);
  }

  function removeNetworkAdmin(uint rol) {
    isIdentityManager(msg.sender);

    _networkAdmin[rol] = false;

    ev_Admin(rol, false);
  }

  function removeIdentityManager(uint rol) {
    isIdentityManager(msg.sender);

    _identityManager[rol] = false;

    ev_IdentityManager(rol, false);
  }

  function removeReputationProvider(uint rol) {
    isIdentityManager(msg.sender);

    _reputationProvider[rol] = false;

    ev_ReputationProvider(rol, false);
  }

  function getRelationship(address id1, address id2, uint rel) constant returns(bool) {

    return _relationships[_rol[id1]][_rol[id2]][rel];
  }

  function getRol(address id) constant returns(uint) {

    return _rol[id];
  }

  function getNumRoles() constant returns(uint) {
      return _numRols;
  }

  function getNetworkAdmin(uint rol) constant returns(bool) {
      return _networkAdmin[rol];
  }

  function getIdentityManager(uint rol) constant returns(bool) {
      return _identityManager[rol];
  }

  function getReputationProvider(uint rol) constant returns(bool) {
      return _reputationProvider[rol];
  }
}