// SPDX-License-Identifier: MIT
pragma solidity 0.8.24;

import {AccessControl} from "@openzeppelin/contracts/access/AccessControl.sol";
import {ReentrancyGuard} from "@openzeppelin/contracts/utils/ReentrancyGuard.sol";
import {IGold} from "./interfaces/IGold.sol";

error EventNotSupported(string eventName);

contract WandsAndWoes is AccessControl, ReentrancyGuard {

    bytes32 public constant MANAGER_ROLE = keccak256("MANAGER_ROLE");
    bytes32 public constant PLAYER_ROLE = keccak256("PLAYER_ROLE");

    mapping(string => bool) private supportedEvents;
    mapping(string => bool) private supportedEventsWithData;

    IGold public gold;

    constructor(address _gold) {
        
        _grantRole(DEFAULT_ADMIN_ROLE, _msgSender());

        gold = IGold(_gold);
    }

    event EmitGameEvent(address player, string indexed eventName);
    event EmitGameEventWithData(address player, string indexed eventName, uint256 indexed data);

    // Admin Functions
    function addEvent(string memory eventName, bool withData) external onlyRole(MANAGER_ROLE) {
        if (withData) {
            supportedEventsWithData[eventName] = true;
        } else {
            supportedEvents[eventName] = true;
        }
    }

    // Public Functions
    function pickupTokens(uint256 amount) external onlyRole(PLAYER_ROLE) {
        gold.mint(msg.sender, amount);
        emit EmitGameEventWithData(msg.sender, "tokens::pickup", amount);
    }

    function emitEvent(string memory eventName) external onlyRole(PLAYER_ROLE) {
        if (!supportedEvents[eventName]) revert EventNotSupported(eventName);
        emit EmitGameEvent(msg.sender, eventName);
    }

    function emitEventWithData(string memory eventName, uint256 data) external onlyRole(PLAYER_ROLE) {
        if (!supportedEvents[eventName]) revert EventNotSupported(eventName);
        emit EmitGameEventWithData(msg.sender, eventName, data);
    }
}