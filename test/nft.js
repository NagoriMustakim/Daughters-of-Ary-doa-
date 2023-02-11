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
            let tx = await nft.connect(acc1).startFirstPublicRound();
            await tx.wait();
            let firstPublicRound = await nft.firstPublicRound()
            expect(firstPublicRound).to.be.equal(true);
            let amount = "1";
            amount = ethers.utils.parseEther(amount)
            amount = ethers.utils.formatUnits(amount.toString())
            let mintLegend = await nft.connect(acc2).mintLegend({ value: ethers.utils.parseEther(amount) });
            await mintLegend.wait()
            let legendNFTCounter = await nft.legendNFTCounter();
            expect(parseInt(legendNFTCounter)).to.be.equal(2);
            // tx = await nft.connect(acc1).startSecondPublicRound()
            // await tx.wait();
            // let second = await nft.secondPublicRound()
            // expect(second).to.be.equal(true);
        })



    })
})


