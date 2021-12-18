const main = async () => {
    const gameContractFactory = await hre.ethers.getContractFactory(
        'MyEpicGame'
    )
    const gameContract = await gameContractFactory.deploy(
        ['Caitlyn', 'Jinx', 'Vander', 'Jayce', 'Vi'], //names
        [
            'https://static1.colliderimages.com/wordpress/wp-content/uploads/2021/09/EN-US_ARCANE_Character_Caitlyn_Vertical_4x5_RGB.jpg',
            'https://static1.colliderimages.com/wordpress/wp-content/uploads/2021/09/EN-US_ARCANE_Character_Jinx_Vertical_4x5_RGB.jpg',
            'https://static1.colliderimages.com/wordpress/wp-content/uploads/2021/09/EN-US_ARCANE_Character_Vander_Vertical_4x5_RGB.jpg',
            'https://static1.colliderimages.com/wordpress/wp-content/uploads/2021/09/EN-US_ARCANE_Character_Jayce_Vertical_4x5_RGB.jpg',
            'https://static1.colliderimages.com/wordpress/wp-content/uploads/2021/09/EN-US_ARCANE_Character_Vi_Vertical_4x5_RGB.jpg',
        ], //images
        [1000, 700, 1500, 1260, 1100], //hp
        [175, 250, 120, 130, 160], //attackDamage
        ['Piltover', 'Zaun', 'Undercity', 'Piltover', 'Zaun'], //originPlaces
        [
            "Piltover's Peacemaker",
            'Flame Chompers',
            'Flashbinder',
            'Mercury Hammer',
            'Golem Gauntlet',
        ] //specialAttack
    )
    await gameContract.deployed()
    console.log('Contract is deployed to: ', gameContract.address)
}

const runMain = async () => {
    try {
        await main()
        process.exit(0)
    } catch (error) {
        console.log(error)
        process.exit(1)
    }
}

runMain()
