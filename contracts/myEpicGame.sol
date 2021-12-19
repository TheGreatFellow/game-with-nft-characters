// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol"; // NFT standard

// Helper functions OpenZeppelin provides.
import "@openzeppelin/contracts/utils/Counters.sol";
import "@openzeppelin/contracts/utils/Strings.sol";

import "hardhat/console.sol"; //hardhat
import "./libraries/Base64.sol";

contract MyEpicGame is ERC721 {
    //Characte attributes
    struct CharacterAttributes {
        uint256 characterIndex;
        string characterName;
        string imageURL;
        uint256 hp;
        uint256 maxHp;
        uint256 attackDamage;
        string origin;
        string specialAttack;
        uint256 level;
    }

    using Counters for Counters.Counter;
    Counters.Counter private _tokenIds; //unique idetifier for nfts

    //array for storing characters
    CharacterAttributes[] defaultCharacters;

    mapping(uint256 => CharacterAttributes) public nftHolderAttributes; // tokenID => nft attributes
    mapping(address => uint256) public nftHolders; // tokenID => nft owner

    constructor(
        string[] memory characterNames,
        string[] memory characterImageURLs,
        uint256[] memory characterHp,
        uint256[] memory characterAttackDmg,
        string[] memory originPlaces,
        string[] memory specialAttacks
    ) ERC721("Arcane", "ARC") {
        for (uint256 i = 0; i < characterNames.length; i += 1) {
            defaultCharacters.push(
                CharacterAttributes({
                    characterIndex: i,
                    characterName: characterNames[i],
                    imageURL: characterImageURLs[i],
                    hp: characterHp[i],
                    maxHp: characterHp[i] + 500,
                    attackDamage: characterAttackDmg[i],
                    origin: originPlaces[i],
                    specialAttack: specialAttacks[i],
                    level: 1
                })
            );

            CharacterAttributes memory c = defaultCharacters[i];

            console.log(
                "Done initializing %s w/ HP %s, img %s",
                c.characterName,
                c.hp,
                c.imageURL
            );
        }

        _tokenIds.increment();
    }

    //this function is to mint the nft characters
    function mintCharacterNFT(uint256 _characterIndex) external {
        uint256 newItemId = _tokenIds.current();

        _safeMint(msg.sender, newItemId);
        //dynamic data to store in a unique nft
        nftHolderAttributes[newItemId] = CharacterAttributes({
            characterIndex: _characterIndex,
            characterName: defaultCharacters[_characterIndex].characterName,
            imageURL: defaultCharacters[_characterIndex].imageURL,
            hp: defaultCharacters[_characterIndex].hp,
            maxHp: defaultCharacters[_characterIndex].maxHp,
            attackDamage: defaultCharacters[_characterIndex].attackDamage,
            origin: defaultCharacters[_characterIndex].origin,
            specialAttack: defaultCharacters[_characterIndex].specialAttack,
            level: defaultCharacters[_characterIndex].level
        });

        console.log(
            "Minted NFT w/ tokenId %s and characterIndex %s",
            newItemId,
            _characterIndex
        );

        nftHolders[msg.sender] = newItemId; //tokenID => owners address

        _tokenIds.increment();
    }

    function tokenURI(uint256 _tokenId)
        public
        view
        override
        returns (string memory)
    {
        CharacterAttributes memory charAttributes = nftHolderAttributes[
            _tokenId
        ];

        string memory strHp = Strings.toString(charAttributes.hp);
        string memory strMaxHp = Strings.toString(charAttributes.maxHp);
        string memory strAttackDamage = Strings.toString(
            charAttributes.attackDamage
        );
        string memory strLevel = Strings.toString(charAttributes.level);

        string memory json = Base64.encode(
            bytes(
                string(
                    abi.encodePacked(
                        '{"name": "',
                        charAttributes.characterName,
                        " -- NFT #: ",
                        Strings.toString(_tokenId),
                        '", "description": "This is an NFT character that lets people play in Legends of Arcane!", "image": "',
                        charAttributes.imageURL,
                        '", "Place of Origin": "',
                        charAttributes.origin,
                        '", "Special Attack": "',
                        charAttributes.specialAttack,
                        '",  "attributes": [ { "trait_type": "Health Points", "value": ',
                        strHp,
                        ', "max_value":',
                        strMaxHp,
                        '}, { "trait_type": "Attack Damage", "value": ',
                        strAttackDamage,
                        ', "trait_type": "Level", "value": ',
                        strLevel,
                        "} ]}"
                    )
                )
            )
        );

        string memory output = string(
            abi.encodePacked("data:application/json;base64,", json)
        );

        return output;
    }
}
