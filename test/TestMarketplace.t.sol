// SPDX-License-Identifier: MIT
pragma solidity 0.8.18;

import {Test, console} from "forge-std/Test.sol";
import {DeployMarketplace} from "../script/DeployMarketplace.s.sol";
import {DeployNFT} from "../script/DeployNFT.s.sol";
import {
    Marketplace,
    Marketplace__NotOwner,
    Marketplace__NotApprovedForMarketplace,
    Marketplace__ItemAlreadyListed,
    Marketplace__PriceZero,
    Marketplace__ItemNotListed,
    Marketplace__NotEnoughEtherSent
} from "../src/Marketplace.sol";
import {NFT} from "../src/NFT.sol";

contract TestMarketplace is Test {
    event ItemListed(address indexed nftContract, uint256 indexed tokenId, uint256 price, address indexed seller);
    event ListingCanceled(address indexed nftContract, uint256 indexed tokenId);
    event ListingUpdated(address indexed nftContract, uint256 indexed tokenId, uint256 price);
    event ItemBought(address indexed nftContract, uint256 indexed tokenId);

    Marketplace public marketplace;
    DeployMarketplace public marketplaceDeployer;
    DeployNFT public nftDeployer;
    NFT public nft;
    address public NFT_OWNER = makeAddr("nft-owner");
    address public USER = makeAddr("user");
    uint256 public constant DEFAULT_ANVIL_PRIVATE_KEY =
        0xac0974bec39a17e36ba4a6b4d238ff944bacb478cbed5efcae784d7bf4f2ff80;
    address public constant DEFAULT_ANVIL_PUBLIC_KEY = 0xf39Fd6e51aad88F6F4ce6aB8827279cffFb92266;

    function setUp() public {
        marketplaceDeployer = new DeployMarketplace();
        marketplace = marketplaceDeployer.run();
        nftDeployer = new DeployNFT();
        nft = nftDeployer.run();
    }

    function testListItemShouldRevertIfIsNotNftOwner() external {
        vm.startPrank(NFT_OWNER);
        uint256 id = nft.mint("TEST_URI"); // mint a token
        nft.approve(address(marketplace), id); // approve marketplace to sell token
        vm.stopPrank();

        vm.startPrank(USER);
        vm.expectRevert(abi.encodeWithSelector(Marketplace__NotOwner.selector, address(nft), id, USER));
        marketplace.listItem(address(nft), id, 1 ether);
        vm.stopPrank();
    }

    function testListItemShouldRevertIfItemIsNotApproved() external {
        vm.startPrank(NFT_OWNER);
        uint256 id = nft.mint("TEST_URI");

        vm.expectRevert(
            abi.encodeWithSelector(
                Marketplace__NotApprovedForMarketplace.selector, address(nft), id, address(marketplace)
            )
        );
        marketplace.listItem(address(nft), id, 1 ether);

        vm.stopPrank();
    }

    function testListItemShouldRevertIfItemIsAlreadyListed() external {
        vm.startPrank(NFT_OWNER);
        uint256 id = nft.mint("TEST_URI");
        nft.approve(address(marketplace), id);
        marketplace.listItem(address(nft), id, 1 ether);

        vm.expectRevert(abi.encodeWithSelector(Marketplace__ItemAlreadyListed.selector, address(nft), id));
        marketplace.listItem(address(nft), id, 1 ether);

        vm.stopPrank();
    }

    function testListItemShouldRevertIfPriceIsZero() external {
        vm.startPrank(NFT_OWNER);
        uint256 id = nft.mint("TEST_URI");
        nft.approve(address(marketplace), id);

        vm.expectRevert(abi.encodeWithSelector(Marketplace__PriceZero.selector));
        marketplace.listItem(address(nft), id, 0 ether);

        vm.stopPrank();
    }

    function testListingItemShouldEmitAnEventWhenAnItemIsListed() external {
        vm.startPrank(NFT_OWNER);
        uint256 id = nft.mint("TEST_URI");
        nft.approve(address(marketplace), id);

        vm.expectEmit(true, true, true, false, address(marketplace));
        emit ItemListed(address(nft), id, 1 ether, NFT_OWNER);
        marketplace.listItem(address(nft), id, 1 ether);

        vm.stopPrank();
    }

    function testGetListingShouldReturnTheCorrectListing() external {
        vm.startPrank(NFT_OWNER);
        uint256 id = nft.mint("TEST_URI");
        nft.approve(address(marketplace), id);
        marketplace.listItem(address(nft), id, 1 ether);

        (uint256 price, address seller) = marketplace.getListing(address(nft), id);
        assertEq(price, 1 ether);
        assertEq(seller, NFT_OWNER);
        vm.stopPrank();
    }

    function testCancelListingShouldRevertIfIsNotNftOwner() external {
        vm.startPrank(NFT_OWNER);
        uint256 id = nft.mint("TEST_URI");
        nft.approve(address(marketplace), id);
        marketplace.listItem(address(nft), id, 1 ether);

        vm.stopPrank();

        vm.startPrank(USER);
        vm.expectRevert(abi.encodeWithSelector(Marketplace__NotOwner.selector, address(nft), id, USER));
        marketplace.cancelListing(address(nft), id);
        vm.stopPrank();
    }

    function testCancelListingShouldRevertIfItemIsNotListed() external {
        vm.startPrank(NFT_OWNER);
        uint256 id = nft.mint("TEST_URI");
        nft.approve(address(marketplace), id);

        vm.expectRevert(abi.encodeWithSelector(Marketplace__ItemNotListed.selector, address(nft), id));
        marketplace.cancelListing(address(nft), id);
        vm.stopPrank();
    }

    function testCancelListingShouldEmitAnEventWhenAnItemIsCanceled() external {
        vm.startPrank(NFT_OWNER);
        uint256 id = nft.mint("TEST_URI");
        nft.approve(address(marketplace), id);
        marketplace.listItem(address(nft), id, 1 ether);

        vm.expectEmit(true, true, true, false, address(marketplace));
        emit ListingCanceled(address(nft), id);
        marketplace.cancelListing(address(nft), id);
        vm.stopPrank();
    }

    function testUpdateListingShouldRevertIfIsNotNftOwner() external {
        vm.startPrank(NFT_OWNER);
        uint256 id = nft.mint("TEST_URI");
        nft.approve(address(marketplace), id);
        marketplace.listItem(address(nft), id, 1 ether);

        vm.stopPrank();

        vm.startPrank(USER);
        vm.expectRevert(abi.encodeWithSelector(Marketplace__NotOwner.selector, address(nft), id, USER));
        marketplace.updateListing(address(nft), id, 2 ether);
        vm.stopPrank();
    }

    function testUpdateListingShouldRevetIfItemIsNotListed() external {
        vm.startPrank(NFT_OWNER);
        uint256 id = nft.mint("TEST_URI");
        nft.approve(address(marketplace), id);

        vm.expectRevert(abi.encodeWithSelector(Marketplace__ItemNotListed.selector, address(nft), id));
        marketplace.updateListing(address(nft), id, 2 ether);
        vm.stopPrank();
    }

    function testUpdateListingShouldRevertIfNewPriceIsZero() external {
        vm.startPrank(NFT_OWNER);
        uint256 id = nft.mint("TEST_URI");
        nft.approve(address(marketplace), id);
        marketplace.listItem(address(nft), id, 1 ether);

        vm.expectRevert(abi.encodeWithSelector(Marketplace__PriceZero.selector));
        marketplace.updateListing(address(nft), id, 0 ether);
        vm.stopPrank();
    }

    function testUpdateListingShouldEmitAnEventWhenAnItemIsUpdated() external {
        vm.startPrank(NFT_OWNER);
        uint256 id = nft.mint("TEST_URI");
        nft.approve(address(marketplace), id);
        marketplace.listItem(address(nft), id, 1 ether);

        vm.expectEmit(true, true, true, false, address(marketplace));
        emit ListingUpdated(address(nft), id, 2 ether);
        marketplace.updateListing(address(nft), id, 2 ether);
        vm.stopPrank();
    }

    function testBuyItemShouldRevertIfItemIsNotListedForSale() external {
        vm.startPrank(NFT_OWNER);
        uint256 id = nft.mint("TEST_URI");
        nft.approve(address(marketplace), id);

        vm.expectRevert(abi.encodeWithSelector(Marketplace__ItemNotListed.selector, address(nft), id));
        marketplace.buyItem(address(nft), id);
        vm.stopPrank();
    }

    function testBuyItemShouldRevertIfNotEnoughEthSent() external {
        vm.startPrank(NFT_OWNER);
        uint256 id = nft.mint("TEST_URI");
        nft.approve(address(marketplace), id);
        marketplace.listItem(address(nft), id, 1 ether);
        vm.stopPrank();

        vm.startPrank(USER);
        vm.deal(USER, 1 ether);
        vm.expectRevert(abi.encodeWithSelector(Marketplace__NotEnoughEtherSent.selector, 1 ether, 0.7 ether));
        marketplace.buyItem{value: 0.7 ether}(address(nft), id);
        vm.stopPrank();
    }

    function testBuyItemShouldUpdateSendTheFundsToTheSeller() external {
        vm.startPrank(NFT_OWNER);
        uint256 id = nft.mint("TEST_URI");
        nft.approve(address(marketplace), id);
        marketplace.listItem(address(nft), id, 1 ether);
        vm.stopPrank();

        vm.prank(USER);
        vm.deal(USER, 1 ether);
        marketplace.buyItem{value: 1 ether}(address(nft), id);
        assertEq(NFT_OWNER.balance, 1 ether - marketplace.COMMISSION_FEE());
    }

    function testBuyItemShouldChangeTheNftOwner() external {
        vm.startPrank(NFT_OWNER);
        uint256 id = nft.mint("TEST_URI");
        nft.approve(address(marketplace), id);
        marketplace.listItem(address(nft), id, 1 ether);
        vm.stopPrank();

        vm.startPrank(USER);
        vm.deal(USER, 1 ether);
        marketplace.buyItem{value: 1 ether}(address(nft), id);
        assertEq(nft.ownerOf(id), USER);
        vm.stopPrank();
    }

    function testBuyItemShouldEmitAnEvent() external {
        vm.startPrank(NFT_OWNER);
        uint256 id = nft.mint("TEST_URI");
        nft.approve(address(marketplace), id);
        marketplace.listItem(address(nft), id, 1 ether);
        vm.stopPrank();

        vm.startPrank(USER);
        vm.deal(USER, 1 ether);
        vm.expectEmit(true, true, true, false, address(marketplace));
        emit ItemBought(address(nft), id);
        marketplace.buyItem{value: 1 ether}(address(nft), id);
    }

    function testWithdrawCommissionShouldRevertIfNotOwner() external {
        vm.startPrank(USER);
        vm.expectRevert("Ownable: caller is not the owner");
        marketplace.withdrawCommission();
        vm.stopPrank();
    }

    function testWithdrawCommissionShouldResetCommissionBalance() external {
        vm.startPrank(NFT_OWNER);
        uint256 id = nft.mint("TEST_URI");
        nft.approve(address(marketplace), id);
        marketplace.listItem(address(nft), id, 1 ether);
        vm.stopPrank();
        vm.prank(USER);
        vm.deal(USER, 1 ether);
        marketplace.buyItem{value: 1 ether}(address(nft), 1);

        vm.prank(DEFAULT_ANVIL_PUBLIC_KEY);
        marketplace.withdrawCommission();
        assertEq(marketplace.s_totalCommission(), 0);
    }

    function testWithdrawCommisionShouldSendTheCommissionToTheOwner() external {
        vm.startPrank(NFT_OWNER);
        uint256 id = nft.mint("TEST_URI");
        nft.approve(address(marketplace), id);
        marketplace.listItem(address(nft), id, 1 ether);
        vm.stopPrank();

        vm.prank(USER);
        vm.deal(USER, 1 ether);
        marketplace.buyItem{value: 1 ether}(address(nft), 1);

        vm.prank(DEFAULT_ANVIL_PUBLIC_KEY);
        uint256 currentBalance = DEFAULT_ANVIL_PUBLIC_KEY.balance;
        marketplace.withdrawCommission();
        assertEq(DEFAULT_ANVIL_PUBLIC_KEY.balance, currentBalance + marketplace.COMMISSION_FEE());
    }
}
