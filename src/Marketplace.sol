// SPDX-License-Identifier: MIT
pragma solidity 0.8.18;

import {IERC721} from "@openzeppelin/contracts/token/ERC721/IERC721.sol";

error Marketplace__ItemAlreadyListed(address nftContract, uint256 tokenId);
error Marketplace__NotOwner(address nftContract, uint256 tokenId, address seller);
error Marketplace__PriceZero();
error Marketplace__NotApprovedForMarketplace(address nftContract, uint256 tokenId, address marketplace);
error Marketplace__ItemNotListed(address nftContract, uint256 tokenId);

contract Marketplace {
    event ItemListed(address indexed nftContract, uint256 indexed tokenId, uint256 price, address indexed seller);
    event ListingCanceled(address indexed nftContract, uint256 indexed tokenId);

    struct Listing {
        uint256 price;
        address seller;
    }

    mapping(address => mapping(uint256 => Listing)) public s_listings; // nftContract => tokenId => Listing

    modifier itemListed(address _nftContract, uint256 _tokenId) {
        Listing memory listing = s_listings[_nftContract][_tokenId];
        if (listing.price > 0) revert Marketplace__ItemAlreadyListed(_nftContract, _tokenId);
        _;
    }

    modifier itemNotListed(address _nftContract, uint256 _tokenId) {
        Listing memory listing = s_listings[_nftContract][_tokenId];
        if (listing.price == 0) revert Marketplace__ItemNotListed(_nftContract, _tokenId);
        _;
    }

    modifier isOwner(address _nftContract, uint256 _tokenId) {
        IERC721 nftContract = IERC721(_nftContract);
        if (nftContract.ownerOf(_tokenId) != msg.sender) {
            revert Marketplace__NotOwner(_nftContract, _tokenId, msg.sender);
        }
        _;
    }

    modifier isItemApprovedForMarketPlace(address _nftContract, uint256 _tokenId) {
        IERC721 nftContract = IERC721(_nftContract);
        if (nftContract.getApproved(_tokenId) != address(this)) {
            revert Marketplace__NotApprovedForMarketplace(_nftContract, _tokenId, address(this));
        }
        _;
    }

    /**
     * @notice List an item for sale
     * @param _nftContract  nft contract address
     * @param _tokenId  nft id
     * @param _price  nft price
     */
    function listItem(address _nftContract, uint256 _tokenId, uint256 _price)
        external
        isOwner(_nftContract, _tokenId)
        isItemApprovedForMarketPlace(_nftContract, _tokenId)
        itemListed(_nftContract, _tokenId)
    {
        if (_price == 0) revert Marketplace__PriceZero();
        s_listings[_nftContract][_tokenId] = Listing({price: _price, seller: msg.sender});
        emit ItemListed(_nftContract, _tokenId, _price, msg.sender);
    }

    /**
     * @notice Cancel a listing
     * @param _nftContract nft contract address
     * @param _tokenId  nft id
     */
    function cancelListing(address _nftContract, uint256 _tokenId)
        external
        isOwner(_nftContract, _tokenId)
        itemNotListed(_nftContract, _tokenId)
    {
        delete s_listings[_nftContract][_tokenId];
        emit ListingCanceled(_nftContract, _tokenId);
    }

    function getListing(address _nftContract, uint256 _tokenId) external view returns (uint256, address) {
        Listing memory listing = s_listings[_nftContract][_tokenId];
        return (listing.price, listing.seller);
    }
}
