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
    struct BigBoss {
        string characterName;
        string imageURL;
        uint256 hp;
        uint256 maxHp;
        uint256 attackDamage;
    }

    BigBoss public bigBoss;

    mapping(address => uint256) public nftHolders; // tokenID => nft owner

    constructor(
        string[] memory characterNames,
        string[] memory characterImageURLs,
        uint256[] memory characterHp,
        uint256[] memory characterAttackDmg,
        string[] memory originPlaces,
        string[] memory specialAttacks,
        string memory bossName,
        string memory bossImageURL,
        uint256 bossHp,
        uint256 bossAttackDmg
    ) ERC721("Arcane", "ARC") {
        bigBoss = BigBoss({
            characterName: bossName,
            imageURL: bossImageURL,
            hp: bossHp,
            maxHp: bossHp,
            attackDamage: bossAttackDmg
        });
        console.log(
            "Done initializing boss %s w/ HP %s, img %s",
            bigBoss.characterName,
            bigBoss.hp,
            bigBoss.imageURL
        );

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

        emit CharacterNFTMinted(msg.sender, newItemId, _characterIndex);
    }

    function attackBoss() public {
        // Get the state of the player's NFT.
        uint256 nftTokenIdOfPlayer = nftHolders[msg.sender];
        CharacterAttributes storage player = nftHolderAttributes[
            nftTokenIdOfPlayer
        ];
        console.log(
            "\nPlayer w/ character %s about to attack. Has %s HP and %s AD",
            player.characterName,
            player.hp,
            player.attackDamage
        );
        console.log(
            "Boss %s has %s HP and %s AD",
            bigBoss.characterName,
            bigBoss.hp,
            bigBoss.attackDamage
        );

        require(player.hp > 0, "Error: character must have HP to attack boss.");

        require(bigBoss.hp > 0, "Error: boss must have HP to attack boss.");

        //attacking the boss
        if (bigBoss.hp < player.attackDamage) {
            bigBoss.hp = 0;
        } else {
            bigBoss.hp = bigBoss.hp - player.attackDamage;
        }

        //attacking the player
        if (player.hp < bigBoss.attackDamage) {
            player.hp = 0;
        } else {
            player.hp = player.hp - bigBoss.attackDamage;
        }

        console.log("Player attacked boss. New boss hp: %s", bigBoss.hp);
        console.log("Boss attacked player. New player hp: %s\n", player.hp);

        emit AttackComplete(bigBoss.hp, player.hp);
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
                        '",  "attributes": [ { "trait_type": "Health Points", "value": ',
                        strHp,
                        ', "max_value":',
                        strMaxHp,
                        '}, {"display_type": "number", "trait_type": "Level", "value": ',
                        strLevel,
                        '}, {"trait_type": "Special Attack", "value": "',
                        charAttributes.specialAttack,
                        '"}, {"trait_type": "Place of Origin", "value": "',
                        charAttributes.origin,
                        '"}, {"display_type": "boost_number", "trait_type": "Attack Damage", "value": ',
                        strAttackDamage,
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

    // Additional utility functions

    function checkIfUserHasNFT()
        public
        view
        returns (CharacterAttributes memory)
    {
        // Get the tokenId of the user's character NFT
        uint256 userNftTokenId = nftHolders[msg.sender];
        if (userNftTokenId > 0) {
            return nftHolderAttributes[userNftTokenId];
        }
        // Else, return an empty character.
        else {
            CharacterAttributes memory emptyStruct;
            return emptyStruct;
        }
    }

    // To display all the characters on the screen
    function getAllDefaultCharacters()
        public
        view
        returns (CharacterAttributes[] memory)
    {
        return defaultCharacters;
    }

    function getBigBoss() public view returns (BigBoss memory) {
        return bigBoss;
    }

    //events to notify when a transaction is done
    event CharacterNFTMinted(
        address sender,
        uint256 tokenId,
        uint256 characterIndex
    );
    event AttackComplete(uint256 newBossHp, uint256 newPlayerHp);
}
