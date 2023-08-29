// SPDX-License-Identifier: MIT
pragma solidity 0.8.18;

import {ERC721} from "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import {ERC721URIStorage} from "@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol";
import {Counters} from "@openzeppelin/contracts/utils/Counters.sol";

contract NFT is ERC721URIStorage {
    event Minted(address indexed contractAddress, address indexed to, uint256 indexed tokenId, string tokenHash);

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
        _mint(msg.sender, newTokenId);
        _setTokenURI(newTokenId, _tokenHash);
        emit Minted(address(this), msg.sender, newTokenId, _tokenHash);
        return newTokenId;
    }

    function _baseURI() internal pure override returns (string memory) {
        return "https://ipfs.io/ipfs/";
    }

    function getTokenCounter() public view returns (uint256) {
        return _tokenIds.current();
    }
}
