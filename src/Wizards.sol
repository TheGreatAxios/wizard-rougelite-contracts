// SPDX-License-Identifier: MIT
pragma solidity 0.8.24;

import {AccessControl} from "@openzeppelin/contracts/access/AccessControl.sol";
import {ERC721} from "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import {Strings} from "@openzeppelin/contracts/utils/Strings.sol";
import {Base64} from "@openzeppelin/contracts/utils/Base64.sol";

error InvalidWizardType(uint8 wizardType);

contract Wizards is ERC721, AccessControl {

    using Strings for uint256;
    using Strings for uint8;

    bytes32 public constant MANAGER_ROLE = keccak256("MANAGER_ROLE");
    uint256 public constant REVIVE_PRICE = 25000e18;

    uint256 public nextCharacterId;

    uint8 public wizardClassCounter;

    mapping(uint256 => WizardInfo) private wizards;
    mapping(uint256 => WizardClass) public wizardClasses;

    struct WizardInfo {
        uint8 wizardClass;
        uint8 armorLevel;
        uint8 damageLevel;
        uint8 healingLevel;
        uint8 healthLevel;
        uint8 speedLevel;
        bool ownsRevive;
    }

    struct WizardClass {
        uint256 id;
        uint256 cost;
        uint256 baseHP;
        uint256 baseDamage;
        uint256 baseSpeed;
        uint256 costInGold;
        string name;
        string lore;
        string description;
        string eventUnlockRequirement;
    }

    constructor() ERC721("Wizards", "WZRD") {
        _grantRole(DEFAULT_ADMIN_ROLE, msg.sender);
        _grantRole(MANAGER_ROLE, msg.sender);

        wizardClasses[1] = WizardClass({
            id: 1,
            name: "APPRENTICE",
            cost: 0,
            baseHP: 75,
            baseDamage: 1e18 * 1, // Using 1e18 for fixed-point support
            baseSpeed: 2,
            lore: "A novice wielder of arcane energies who has just begun their journey. Though lacking experience, the Apprentice's potential is undeniable, with natural talent for simple but effective magic.",
            description: "The starting wizard class, perfect for learning the basics of magical combat.",
            costInGold: 0,
            eventUnlockRequirement: ""
        });

        wizardClasses[2] = WizardClass({
            id: 2,
            name: "CONJURER",
            cost: 2500,
            baseHP: 90,
            baseDamage: 1e18 * 1.1,
            baseSpeed: 2,
            lore: "Trained in the art of protective magic, Conjurers specialize in defensive spells and barriers that allow them to survive where others would fall.",
            description: "A defensive spellcaster who focuses on damage mitigation.",
            costInGold: 2500e18,
            eventUnlockRequirement: ""
        });

        wizardClasses[3] = WizardClass({
            id: 3,
            name: "MAGICIAN",
            cost: 8500,
            baseHP: 105,
            baseDamage: 1e18 * 1.2,
            baseSpeed: 2,
            lore: "Masters of swift, precise spellcasting, Magicians blend combat magic with finesse, striking with deadly accuracy before enemies can react.",
            description: "A dexterous spellcaster specializing in quick, precise attacks.",
            costInGold: 8500e18,
            eventUnlockRequirement: ""
        });

        wizardClasses[4] = WizardClass({
            id: 4,
            name: "WARLOCK",
            cost: 27500,
            baseHP: 115,
            baseDamage: 1e18 * 1.3,
            baseSpeed: 2,
            lore: "Drawing power from ancient pacts with primordial entities, Warlocks command devastating area attacks that can decimate groups of enemies at once.",
            description: "A powerful spellcaster focused on area-of-effect damage.",
            costInGold: 27500e18,
            eventUnlockRequirement: ""
        });

        wizardClasses[5] = WizardClass({
            id: 5,
            name: "SORCERER",
            cost: 75000,
            baseHP: 130,
            baseDamage: 1e18 * 1.4,
            baseSpeed: 2,
            lore: "Born with innate connection to elemental forces, Sorcerers channel raw magical energy through their body, creating devastating chain reactions of power.",
            description: "An elemental master who harnesses lightning to damage multiple foes.",
            costInGold: 75000e18,
            eventUnlockRequirement: ""
        });

        wizardClasses[6] = WizardClass({
            id: 6,
            name: "WIZARD",
            cost: 125000,
            baseHP: 145,
            baseDamage: 1e18 * 1.6,
            baseSpeed: 2,
            lore: "The pinnacle of traditional arcane study, true Wizards have mastered fundamental magical principles, allowing them to cast with perfect efficiency and devastating effect.",
            description: "A master of traditional spellcraft with powerful ice magic.",
            costInGold: 125000e18,
            eventUnlockRequirement: ""
        });

        wizardClasses[7] = WizardClass({
            id: 7,
            name: "ARCHMAGE",
            cost: 250000,
            baseHP: 175,
            baseDamage: 1e18 * 1.8,
            baseSpeed: 2,
            lore: "Revered leaders of magical academies who have unlocked the deepest secrets of spellcraft. Archmages can manifest guardian constructs that fight alongside them while they cast devastating spells.",
            description: "A supreme spellcaster who combines offensive magic with protective sentinels.",
            costInGold: 250000e18,
            eventUnlockRequirement: ""
        });

        wizardClasses[8] = WizardClass({
            id: 8,
            name: "VOID MANCER",
            cost: 500000,
            baseHP: 200,
            baseDamage: 1e18 * 2.5,
            baseSpeed: 2,
            lore: "Having glimpsed the same cosmic emptiness that powers Nihilus, Void Mancers channel the raw energy of nothingness. Their connection to the void grants them unparalleled destructive potential, but risks corruption with each spell cast.",
            description: "The ultimate spellcaster who harnesses the same void energy as Nihilus.",
            costInGold: 500000e18,
            eventUnlockRequirement: "boss::defeat::nihilus"
        });

        wizardClassCounter = 8;
    }

    function createWizard(address to, uint8 wizardType) public onlyRole(MANAGER_ROLE) returns (uint256) {
        uint256 tokenId = nextCharacterId++;
        _safeMint(to, tokenId);

        if (wizardType > wizardClassCounter) revert InvalidWizardType(wizardType);

        // Only Allows Open
        wizards[tokenId].wizardClass = wizardType;

        return tokenId;
    }

    // function upgradeArmor(uint256 wizardId) external onlyRole(MANAGER_ROLE) returns (uint256) {
    //     if (wizards[wizardId].armorLevel + 1 <= )
    //     wizards[wizardId].armorLevel++;
    // }
    
    function getWizardClass(uint256 id) public view returns (WizardClass memory) {
        return wizardClasses[id];
    }

    function tokenURI(uint256 tokenId) public view override returns (string memory) {
        
        WizardInfo memory wizard = wizards[tokenId];
        WizardClass memory wizardClass = getWizardClass(wizard.wizardClass);

        string memory json = string.concat(
            "{",
                string.concat(
                    "\"name\": \"",
                    wizardClass.name,
                    "\","
                ),
                string.concat(
                    "\"description\": \"",
                    wizardClass.description,
                    "\","
                ),
                "\"attributes\": [",
                    string.concat(
                        "{\"trait_type\": \"Lore\", \"value\": \"",
                        wizardClass.lore,
                        "\"},"
                    ),
                    string.concat(
                        "{\"trait_type\": \"Cost to Unlock\", \"value\": \"",
                        wizardClass.costInGold.toString(),
                        "\"},"
                    ),
                    string.concat(
                        "{\"trait_type\": \"Event Required to Unlock\", \"value\": \"",
                        wizardClass.eventUnlockRequirement,
                        "\"},"
                    ),
                    string.concat(
                        "{\"trait_type\": \"Armor Level\", \"value\": \"",
                        wizard.armorLevel.toString(),
                        "\"},"
                    ),
                    string.concat(
                        "{\"trait_type\": \"Damage Level\", \"value\": \"",
                        wizard.damageLevel.toString(),
                        "\"},"
                    ),
                    string.concat(
                        "{\"trait_type\": \"Healing Level\", \"value\": \"",
                        wizard.healingLevel.toString(),
                        "\"},"
                    ),
                    string.concat(
                        "{\"trait_type\": \"Health Level\", \"value\": \"",
                        wizard.healthLevel.toString(),
                        "\"},"
                    ),
                    string.concat(
                        "{\"trait_type\": \"Speed Level\", \"value\": \"",
                        wizard.speedLevel.toString(),
                        "\"},"
                    ),
                    string.concat(
                        "{\"trait_type\": \"Owns Revive\", \"value\": \"",
                        wizard.ownsRevive ? "Yes" : "No",
                        "\"}"
                    ),
                "]",
            "}"
        );

        string memory base64Json = Base64.encode(bytes(json));
        return string.concat("data:application/json;base64,", base64Json);
    }

    function supportsInterface(bytes4 interfaceId)
        public
        view
        override(ERC721, AccessControl)
        returns (bool)
    {
        return super.supportsInterface(interfaceId);
    }

    /***********************************************/
    /************ Internal Pricing Functions *******/
    /***********************************************/
    function getArmorPrices() internal pure returns (uint256[7] memory) {
        return [
            uint256(200e18),
            1000e18,
            5000e18,
            10000e18,
            20000e18,
            35000e18,
            50000e18
        ];
    }

    function getDamagePrices() internal pure returns (uint256[7] memory) {
        return [
            uint256(200e18),
            1000e18,
            5000e18,
            10000e18,
            20000e18,
            35000e18,
            50000e18
        ];
    }

    function getHealingPrices() internal pure returns (uint256[7] memory) {
        return [
            uint256(200e18),
            1000e18,
            5000e18,
            10000e18,
            50000e18,
            65000e18,
            100000e18
        ];
    }

    function getHealthPrices() internal pure returns (uint256[7] memory) {
        return [
            uint256(200e18),
            1000e18,
            10000e18,
            25000e18,
            50000e18,
            75000e18,
            100000e18
        ];
    }

    function getSpeedPrices() internal pure returns (uint256[5] memory) {
        return [
            uint256(2500e18),
            7000e18,
            12500e18,
            25000e18,
            50000e18
        ];
    }
}