//SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.18;

import "hardhat/console.sol";
import "@openzeppelin/contracts/utils/Counters.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol";
import "@openzeppelin/contracts/token/ERC721/ERC721.sol";


// GOERLI contract address 0x9d49c64Ea953244B94C0E9240454BC662dAE86a2

contract NFTMarketPlace is ERC721URIStorage {
    using Counters for Counters.Counter;

    Counters.Counter private _tokenIds;

    Counters.Counter private _itemsSold;

    address payable owner;

    uint256 listPrice = 0.01 ether;

    struct ListedToken {
        uint256 tokenId;
        address payable owner;
        address payable seller;
        uint256 price;
        bool currentlyListed;
    }

    event ListedSuccess (
        uint256 indexed tokenId,
        address owner,
        address  seller,
        uint256 price,
        bool currentlyListed
    );

    mapping(uint256 => ListedToken) private idToListedToken;

    modifier onlyOwner {
        require(payable(msg.sender) == owner, "only owner allowed");
        _;
    }

    constructor() ERC721("NFTMarketPlace", "NFTM") {
        owner = payable(msg.sender);
    }

    function getListPrice() public returns (uint256) {
        return listPrice;
    }

    function updateListPrice(uint256 _listPrice) public payable onlyOwner {
        listPrice = _listPrice;
    }

    function getLatestListedToken() public returns (ListedToken memory) {
        uint256 currentId = _tokenIds.current();
        return idToListedToken[currentId];
    }

    function getListedTokenById(uint256 id) public returns (ListedToken memory) {
        return idToListedToken[id];
    }

    function getCurrentTokenId() public returns (uint256) {
        return _tokenIds.current();
    }

    function createToken(string memory tokenUri, uint256 price) public payable returns (uint256){
        _tokenIds.increment();
        uint256 newTokenId = _tokenIds.current();

        //Mint the NFT with tokenId newTokenId to the address who called createToken
        _safeMint(msg.sender, newTokenId);

        //Map the tokenId to the tokenURI (which is an IPFS URL with the NFT metadata)
        _setTokenURI(newTokenId, tokenUri);

        //Helper function to update Global variables and emit an event
        createListedToken(newTokenId, price);

        return newTokenId;
    }

    modifier validListPrice {
        require(msg.value == listPrice, "Msg value should equal List Price set");
        _;
    }

    function createListedToken(uint256 tokenId, uint256 price) private validListPrice {
        idToListedToken[tokenId] = ListedToken(
            tokenId,
            payable(address(this)),
            payable(msg.sender),
            price,
            true
        );

        // transfer token sender to current contract
        _transfer(msg.sender, address(this), tokenId);

        //Emit the event for successful transfer. The frontend parses this message and updates the end user
        emit ListedSuccess(tokenId, address(this), msg.sender, price, true);
    }

    function getAllNFTs() public returns (ListedToken[] memory) {
        uint nftCount = _tokenIds.current();
        ListedToken[] memory nfts = new ListedToken[](nftCount);
        for(uint i = 0; i < nftCount; i++) {
            ListedToken storage listedToken = idToListedToken[i+1];
            nfts[i] = listedToken;
        }
        return nfts;
    }

    function getMyNFTs() public returns (ListedToken[] memory) {
        uint nftCount = _tokenIds.current();

        // count nft owned by sender
        uint count = 0;
        for(uint i = 0; i < nftCount; i++) {
            ListedToken storage listedToken = idToListedToken[i+1];
            if(listedToken.owner == msg.sender || listedToken.seller == msg.sender) {
                count++;
            }
        }

        //
        ListedToken[] memory nfts = new ListedToken[](count);
        uint currentIndex = 0;
        for(uint i = 0; i < nftCount; i++) {
            ListedToken storage listedToken = idToListedToken[i+1];
            if(listedToken.owner == msg.sender || listedToken.seller == msg.sender) {
                nfts[currentIndex] = listedToken;
                currentIndex++;
            }
        }

        return nfts;
    }

    function executeSale(uint256 tokenId) public payable {
        uint price = idToListedToken[tokenId].price;
        address seller = idToListedToken[tokenId].seller;
        require(price == msg.value, "please submit correct price!");

        idToListedToken[tokenId].currentlyListed = true;

        idToListedToken[tokenId].seller = payable(msg.sender);

        _itemsSold.increment();

        //Actually transfer the token to the new owner
        _transfer(address(this), msg.sender, tokenId);

         //approve the marketplace to sell NFTs on your behalf
        approve(address(this), tokenId);

        //Transfer the listing fee to the marketplace creator
        payable(owner).transfer(listPrice);

        //Transfer the proceeds from the sale to the seller of the NFT
        payable(seller).transfer(msg.value);

    }

}

