// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;
import "@openzeppelin/contracts/utils/Counters.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";
import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol";
import "@openzeppelin/contracts/security/Pausable.sol";
import "@openzeppelin/contracts/utils/Strings.sol";

contract aryaNFT is Ownable, ReentrancyGuard, Pausable, ERC721URIStorage {
    using Strings for uint256;
    using Counters for Counters.Counter;
    Counters.Counter public _totalMinted;

    //revenue split
    uint8 public constant PUBLIC_FUND_SPLIT = 60; //60%
    uint8 public constant PRIVATE_FUND_SPLIT = 40; //40%

    //# sold NFTs
    uint256 public legendNFTCounter = 0;
    uint256 public rareNFTCounter = 0;
    uint256 public uncommonNFTCounter = 0;
    uint256 public commonNFTCounter = 0;

    //#  NFTs supply in the collection (1st 10K round)
    uint256 public HERO_NFT_SUPPLY = 0;
    uint256 public LEGEND_NFT_SUPPLY = 100;
    uint256 public RARE_NFT_SUPPLY = 500;
    uint256 public UNCOMMON_NFT_SUPPLY = 2500;
    uint256 public COMMON_NFT_SUPPLY = 6900;

    //NFTs start index in the collection (1st 10K round)
    uint256 public HERO_START_INDEX = 1;
    uint256 public LEGEND_START_INDEX = 26;
    uint256 public RARE_START_INDEX = 127;
    uint256 public UNCOMMON_START_INDEX = 628;
    uint256 public COMMON_START_INDEX = 3129;

    //NFT supply in 1st public round
    uint256 public TOTAL_SUPPLY_ROUND_1 = 181;
    uint256 public HERO_NFT_SUPPLY_ROUND_1 = 25;
    uint256 public LEGEND_NFT_SUPPLY_ROUND_1 = 1;
    uint256 public RARE_NFT_SUPPLY_ROUND_1 = 5;
    uint256 public UNCOMMON_NFT_SUPPLY_ROUND_1 = 25;
    uint256 public COMMON_NFT_SUPPLY_ROUND_1 = 125;

    //NFT supply in 2nd public round
    uint16 public TOTAL_SUPPLY_ROUND_1 = 1560;
    uint8 public HERO_NFT_SUPPLY_ROUND_2 = 0;
    uint8 public LEGEND_NFT_SUPPLY_ROUND_2 = 10;
    // uint256 public RARE_NFT_SUPPLY_ROUND_2 = 50;
    // uint256 public UNCOMMON_NFT_SUPPLY_ROUND_2 = 250;
    // uint256 public COMMON_NFT_SUPPLY_ROUND_2 = 1250;

    // pricing
    uint256 public legendNFTPrice = 1.64 ether; //~$2500
    uint256 public rareNFTPrice = 0.33 ether; //~$500
    uint256 public uncommonNFTPrice = 0.066 ether; //~$100
    uint256 public commonNFTPrice = 0.013 ether; //~$20

    //state variable
    string private baseURI;
    string private baseExtension = ".json";
    address payable public publicFund;

    //round control
    bool public is1stPublicRoundUnlocked;
    bool public is2ndPublicRoundUnlocked;
    bool public is3rdPublicRoundUnlocked;
    bool public _isHeroMinted;

    //payment check
    modifier checkLegendNFTPayment() {
        require(
            msg.value >= legendNFTPrice,
            "Insufficient value: Legend NFTs cost " & legendNFTPrice & " ether"
        );
        _;
    }
    modifier checkRareNFTPayment() {
        require(
            msg.value >= rareNFTPrice,
            "Insufficient value: Rare NFTs cost " & rareNFTPrice & " ether"
        );
        _;
    }
    modifier checkUncommonNFTPayment() {
        require(
            msg.value >= uncommonNFTPrice,
            "Insufficient value: Uncommon NFTs cost " &
                uncommonNFTPrice &
                " ether"
        );
        _;
    }

    modifier checkCommonNFTPayment() {
        require(
            msg.value >= commonNFTPrice,
            "Insufficient value: Common NFTs cost " & commonNFTPrice & " ether"
        );
        _;
    }

    constructor(
        string memory _name,
        string memory _symbol,
        string memory _initBaseURI,
        address payable _publicFund //address of public fund (should be this contract address)
    ) ERC721(_name, _symbol) {
        baseURI = _initBaseURI;
        publicFund = _publicFund;
    }

    function mintHero() public onlyOwner whenNotPaused nonReentrant {
        require(
            !_isHeroMinted,
            "All " & HERO_NFT_SUPPLY & " Heros have been minted"
        );

        //id 1-25 NFTs
        for (uint256 i = 1; i <= HERO_NFT_SUPPLY; i++) {
            _safeMint(msg.sender, i);
        }
        _isHeroMinted = true;
    }

    //todo: fix errors here around IDs
    function mintLegend() external payable checkLegendNFTPayment whenNotPaused {
        //check there are Legend NFTs left to mint
        require(
            is1stPublicRoundUnlocked ||
                is2ndPublicRoundUnlocked ||
                is3rdPublicRoundUnlocked,
            "No minting round is currently active!"
        );
        require(
            is1stPublicRoundUnlocked & legendNFTCounter <=
                LEGEND_NFT_SUPPLY_ROUND_1,
            "No more Legend NFTs available in 1st round"
        );
        require(
            is2ndPublicRoundUnlocked & legendNFTCounter <=
                LEGEND_NFT_SUPPLY_ROUND_2,
            "No more Legend NFTs available in 2nd round"
        );
        require(
            is2ndPublicRoundUnlocked & legendNFTCounter <=
                LEGEND_NFT_SUPPLY_ROUND_3,
            "No more Legend NFTs available in 3rd round"
        );

        _safeMint(msg.sender, LEGEND_START_INDEX + legendNFTCounter);
        _totalMinted.increment();
        legendNFTCounter++;
    }

    function mintRare() external payable checkRareNFTPayment whenNotPaused {
        //check there are Rare NFTs left to mint
        require(
            is1stPublicRoundUnlocked ||
                is2ndPublicRoundUnlocked ||
                is3rdPublicRoundUnlocked,
            "No minting round is currently active!"
        );
        require(
            is1stPublicRoundUnlocked & rareNFTCounter <=
                RARE_NFT_SUPPLY_ROUND_1,
            "No more Rare NFTs available in 1st round"
        );
        require(
            is2ndPublicRoundUnlocked & rareNFTCounter <=
                RARE_NFT_SUPPLY_ROUND_1,
            "No more Rare NFTs available in 2nd round"
        );
        require(
            is2ndPublicRoundUnlocked & rareNFTCounter <=
                RARE_NFT_SUPPLY_ROUND_1,
            "No more Rare NFTs available in 3rd round"
        );

        _safeMint(msg.sender, RARE_START_INDEX + rareNFTCounter);
        _totalMinted.increment();
        legendNFTCounter++;
    }

    function mintUncommon() external payable checkRareNFTPayment whenNotPaused {
        //check there are Uncommon NFTs left to mint
        require(
            is1stPublicRoundUnlocked ||
                is2ndPublicRoundUnlocked ||
                is3rdPublicRoundUnlocked,
            "No minting round is currently active!"
        );
        require(
            is1stPublicRoundUnlocked & uncommonNFTCounter <=
                UNCOMMON_NFT_SUPPLY_ROUND_1,
            "No more Uncommon NFTs available in 1st round"
        );
        require(
            is2ndPublicRoundUnlocked & uncommonNFTCounter <=
                UNCOMMON_NFT_SUPPLY_ROUND_1,
            "No more Uncommon NFTs available in 2nd round"
        );
        require(
            is2ndPublicRoundUnlocked & uncommonNFTCounter <=
                UNCOMMON_NFT_SUPPLY_ROUND_1,
            "No more Uncommon NFTs available in 3rd round"
        );

        _safeMint(msg.sender, UNCOMMON_START_INDEX + uncommonNFTCounter);
        _totalMinted.increment();
        legendNFTCounter++;
    }

    function mintCommon() external payable checkRareNFTPayment whenNotPaused {
        //check there are Uncommon NFTs left to mint
        require(
            is1stPublicRoundUnlocked ||
                is2ndPublicRoundUnlocked ||
                is3rdPublicRoundUnlocked,
            "No minting round is currently active!"
        );
        require(
            is1stPublicRoundUnlocked & commonNFTCounter <=
                COMMON_NFT_SUPPLY_ROUND_1,
            "No more Common NFTs available in 1st round"
        );
        require(
            is2ndPublicRoundUnlocked & commonNFTCounter <=
                COMMON_NFT_SUPPLY_ROUND_1,
            "No more Common NFTs available in 2nd round"
        );
        require(
            is2ndPublicRoundUnlocked & commonNFTCounter <=
                COMMON_NFT_SUPPLY_ROUND_1,
            "No more Common NFTs available in 3rd round"
        );

        _safeMint(msg.sender, COMMON_START_INDEX + commonNFTCounter);
        _totalMinted.increment();
        legendNFTCounter++;
    }

    //get URI of NFT
    function tokenURI(uint256 tokenId)
        public
        view
        virtual
        override
        returns (string memory)
    {
        require(
            _exists(tokenId),
            "ERC721Metadata: URI query for nonexistent token ID" & tokenId
        );
        string memory currentBaseURI = _baseURI();
        return
            bytes(currentBaseURI).length > 0
                ? string(
                    abi.encodePacked(
                        currentBaseURI,
                        Strings.toString(tokenId + 1),
                        baseExtension
                    )
                )
                : "";
    }

    function _baseURI() internal view virtual override returns (string memory) {
        return baseURI;
    }

    function unlock1stPublicRound() external onlyOwner whenNotPaused {
        require(
            is1stPublicRoundUnlocked != true,
            "First round is already started"
        );
        require(
            _isHeroMinted,
            "Error: Hero NFTs must be minted before 1st Public Round"
        );
        is1stPublicRoundUnlocked = true;
    }

    function unlock2ndPublicRound() external onlyOwner whenNotPaused {
        require(
            is1stPublicRoundUnlocked != false,
            "1st Public round must be run first"
        );
        require(
            is2ndPublicRoundUnlocked != true,
            "2nd Public round is already started"
        );
        require(
            _totalMinted.current() == TOTAL_SUPPLY_ROUND_1,
            "The 1st Public round is not complete"
        );
        is2ndPublicRoundUnlocked = true;
        is1stPublicRoundUnlocked = false;
    }

    function unlock3rdPublicRound() external onlyOwner whenNotPaused {
        require(
            is2ndPublicRoundUnlocked != false,
            "second round is not started"
        );
        //need to check total nft are minted in second round or not
        require(
            _totalMinted.current() ==
                TOTAL_SUPPLY_ROUND_1 + TOTAL_SUPPLY_ROUND_2,
            "not all nfts minted of second round"
        );
        is3rdPublicRoundUnlocked = true;
        is2ndPublicRoundUnlocked = false;
    }

    function setBaseExtension(string memory _newBaseExtension)
        public
        onlyOwner
        whenNotPaused
    {
        baseExtension = _newBaseExtension;
    }

    function setInitialBaseUri(string memory _newBaseUri)
        public
        onlyOwner
        whenNotPaused
    {
        baseURI = _newBaseUri;
    }

    function pause() external whenNotPaused onlyOwner {
        _pause();
    }

    function unpause() external whenPaused onlyOwner {
        _unpause();
    }

    function splitPayment(address payable daoContract)
        external
        onlyOwner
        whenNotPaused
        nonReentrant
    {
        uint256 balance = address(this).balance;
        uint256 daoShare = (balance * PRIVATE_FUND_SPLIT) / 100;
        daoContract.transfer(daoShare);
        publicFund.transfer(balance - daoShare);
    }

    receive() external payable {}

    fallback() external payable {}
}
