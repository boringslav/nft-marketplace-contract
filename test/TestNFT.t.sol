// SPDX-License-Identifier: MIT
pragma solidity 0.8.18;

import {Test, console} from "forge-std/Test.sol";
import {DeployNFT} from "../script/DeployNFT.s.sol";
import {NFT} from "../src/NFT.sol";

contract TestNFT is Test {
    string constant NFT_NAME = "TEST_NAME";
    string constant NFT_SYMBOL = "TEST_SYMBOL";
    string constant NFT_URI = "TEST_URI";
    NFT public nft;
    DeployNFT public deployer;

    function setUp() public {
        deployer = new DeployNFT();
        nft = deployer.run(NFT_NAME, NFT_SYMBOL);
    }

    function testInitialization() external {
        assertEq(nft.name(), NFT_NAME);
        assertEq(nft.symbol(), NFT_SYMBOL);
    }

    function testMintShouldUpdateTokenUriMapping() external {
        uint256 tokenId = nft.mint(NFT_URI);
        assertEq(nft.tokenURI(tokenId), NFT_URI);
    }

    function testMintShouldUpdateTokenCounter() external {
        uint256 tokenCounter = nft.getTokenCounter();
        nft.mint(NFT_URI);
        assertEq(nft.getTokenCounter(), tokenCounter + 1);
    }
}
