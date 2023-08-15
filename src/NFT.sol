// SPDX-License-Identifier: MIT
pragma solidity 0.8.18;

import {ERC721} from "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import {ERC721URIStorage} from "@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol";
import {Counters} from "@openzeppelin/contracts/utils/Counters.sol";
import {console} from "forge-std/Test.sol";

contract NFT is ERC721URIStorage {
    using Counters for Counters.Counter;

    Counters.Counter private _tokenIds;
    mapping(uint256 => string) public s_tokenHashes; //id => hash

    constructor(string memory _name, string memory _symbol) ERC721(_name, _symbol) {}

    /**
     * @notice Mint a new token
     * @param _tokenHash metadata uri (ipfs CID hash)
     */
    function mint(string memory _tokenHash) public returns (uint256) {
        _tokenIds.increment();
        uint256 newTokenId = _tokenIds.current();
        s_tokenHashes[newTokenId] = _tokenHash;
        _mint(msg.sender, newTokenId);
        return newTokenId;
    }

    /**
     * TODO uri storage
     * @notice Get the metadata uri (ipfs CID hash) of a token
     * @param _tokenId nft id
     */
    function tokenURI(uint256 _tokenId) public view override returns (string memory) {
        _requireMinted(_tokenId);

        string memory baseURI = _baseURI();
        return bytes(baseURI).length > 0 ? string(abi.encodePacked(baseURI, s_tokenHashes[_tokenId])) : "";
    }

    function _baseURI() internal pure override returns (string memory) {
        return "https://ipfs.io/ipfs/";
    }

    function getTokenCounter() public view returns (uint256) {
        return _tokenIds.current();
    }
}
