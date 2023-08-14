// SPDX-License-Identifier: MIT
pragma solidity 0.8.18;

import {ERC721} from "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import {ERC721URIStorage} from "@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol";
import {Counters} from "@openzeppelin/contracts/utils/Counters.sol";

contract NFT is ERC721 {
    using Counters for Counters.Counter;

    Counters.Counter private _tokenIds;
    mapping(uint256 => string) private s_tokenURIs; //id => uri (metadata)

    constructor(string memory _name, string memory _symbol) ERC721(_name, _symbol) {}

    /**
     * @notice Mint a new token
     * @param _tokenURI metadata uri (ipfs link)
     */
    function mint(string memory _tokenURI) public returns (uint256) {
        _tokenIds.increment();
        uint256 newTokenId = _tokenIds.current();
        s_tokenURIs[newTokenId] = _tokenURI;
        _mint(msg.sender, newTokenId);
        return newTokenId;
    }

    function tokenURI(uint256 _tokenId) public view override returns (string memory) {
        return s_tokenURIs[_tokenId];
    }

    function getTokenCounter() public view returns (uint256) {
        return _tokenIds.current();
    }
}
