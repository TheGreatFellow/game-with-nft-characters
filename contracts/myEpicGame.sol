// SPDX-License-Identifier: UNLICENSED

pragma solidity ^0.8.0;

import "hardhat/console.sol";

contract MyEpicGame {
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

    //default data for characters
    CharacterAttributes[] defaultCharacters;

    constructor(
        string[] memory characterNames,
        string[] memory characterImageURLs,
        uint256[] memory characterHp,
        uint256[] memory characterAttackDmg,
        string[] memory originPlaces,
        string[] memory specialAttacks
    ) {
        for (uint256 i = 0; i < characterNames.length; i += 1) {
            defaultCharacters.push(
                CharacterAttributes({
                    characterIndex: i,
                    characterName: characterNames[i],
                    imageURL: characterImageURLs[i],
                    hp: characterHp[i],
                    maxHp: characterHp[i],
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
    }
}
