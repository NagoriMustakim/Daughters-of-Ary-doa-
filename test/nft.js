const { expect } = require('chai');
const { ethers } = require('hardhat');

const tokens = (n) => {
    return ethers.utils.parseUnits(n.toString(), 'ether')
}

describe("NFT contract", () => {
    //testing nft smart contract
    let acc1, acc2, acc3, acc4, nft
    //constructor variable
    let name = "arya"
    let symbol = "ARYA"
    let initBaseURI = "ipfs://bafybeiatthditre4mlrdjg4ewg52yu3ab3qcgtmefnlkzjrvba3dr3x62y/"
    let publicFundAddress = "0x39b62D34744f65Dd1ccE4A56558ae91133476C6E"
    beforeEach(async () => {
        [acc1, acc2, acc3, acc4] = await ethers.getSigners()
        const NFT = await ethers.getContractFactory("aryaNFT")
        nft = await NFT.deploy(name, symbol, initBaseURI, publicFundAddress)
        let transaction = await nft.connect(acc1).mintHero()
        await transaction.wait();

    })
    describe("Testing state veraible", () => {
        it("legendNFTCounter", async () => {
            let legendNFTCounter = await nft.legendNFTCounter();
            expect(parseInt(legendNFTCounter)).to.be.equal(1);
        })
        it("firstPublicRound", async () => {
            let firstRound = await nft.firstPublicRound();
            expect(firstRound).to.be.equal(false);
        })
        it("firstPublicRound", async () => {
            let firstRound = await nft.firstPublicRound();
            expect(firstRound).to.be.equal(false);
        })
        it("Balance of hero nft owner", async () => {
            // let owner = await nft.owner();
            // console.log(owner);
            // console.log(acc1.address);
            let balance = await nft.balanceOf(acc1.address)
            expect(parseInt(balance)).to.be.equal(25);
            for (let i = 0; i < 25; i++) {
                let tokenuri = await nft.tokenURI(i);
                console.log((tokenuri));
            }
        })

        it("Start public round", async () => {
            //stating first public round
            let tx = await nft.connect(acc1).startFirstPublicRound();
            await tx.wait();
            //testing first public round
            let firstPublicRound = await nft.firstPublicRound()
            expect(firstPublicRound).to.be.equal(true);
            //eth to contract
            let options = { value: ethers.utils.parseEther("2.0") }
            //minting legend nft
            let mintLegend = await nft.connect(acc2).mintLegend(options);
            await mintLegend.wait()
            //testing legend counter
            let legendNFTCounter = await nft.legendNFTCounter();
            expect(parseInt(legendNFTCounter)).to.be.equal(2);
            //checkinh tokenuri
            let tokenuri = await nft.tokenURI(25);
            console.log((tokenuri));
            //owner of contract
            let ownerofnft = await nft.ownerOf(25);
            console.log(ownerofnft);
            console.log(acc2.address);
            //checking rarenftcounter
            let rareNFTCounter = await nft.rareNFTCounter();
            expect(parseInt(rareNFTCounter)).to.be.equal(1);
            //eth to contract
            options = { value: ethers.utils.parseEther("0.33") }
            //minting all rare nft in first round
            for (let i = 0; i < 5; i++) {
                let mintrare = await nft.connect(acc3).mintRare(options);
                await mintrare.wait()
            }
            rareNFTCounter = await nft.rareNFTCounter();
            expect(parseInt(rareNFTCounter)).to.be.equal(6);
           
            
            //acc2 is not owner of nft contract thus it will give error that's why below code is commented
            // tx = await nft.connect(acc2).startSecondPublicRound()
            // await tx.wait();

            //starting 2nd public round before starting second round we need to mint all nft in first round
            // tx = await nft.connect(acc1).startSecondPublicRound()
            // await tx.wait();
            // let second = await nft.secondPublicRound()
            // expect(second).to.be.equal(true);
        })



    })
})


