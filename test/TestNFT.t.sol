// SPDX-License-Identifier: MIT
pragma solidity 0.8.18;

import {Test, console} from "forge-std/Test.sol";
import {DeployNFT} from "../script/DeployNFT.s.sol";
import {NFT} from "../src/NFT.sol";

contract TestNFT is Test {
    string constant NFT_NAME = "Boringtoken";
    string constant NFT_SYMBOL = "BRN";
    string constant NFT_HASH = "QmcpSBhpHsi3H5q4bHGE46zbXhYqZW1D4gnoLeyQFw58D8";
    NFT public nft;
    DeployNFT public deployer;

    function setUp() public {
        deployer = new DeployNFT();
        nft = deployer.run();
    }

    function testInitialization() external {
        assertEq(nft.name(), NFT_NAME);
        assertEq(nft.symbol(), NFT_SYMBOL);
    }

    function testTokenUriShouldReturnIpfsLink() external {
        uint256 tokenId = nft.mint(NFT_HASH);
        console.log("tokenURI: %s", nft.tokenURI(tokenId));
        assertEq(nft.tokenURI(tokenId), string(abi.encodePacked("https://ipfs.io/ipfs/", NFT_HASH)));
    }

    function testMintShouldUpdateTokenCounter() external {
        uint256 tokenCounter = nft.getTokenCounter();
        nft.mint(NFT_HASH);
        assertEq(nft.getTokenCounter(), tokenCounter + 1);
    }
}
