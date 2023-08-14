// SPDX-License-Identifier: MIT
pragma solidity 0.8.18;

import {Test, console} from "forge-std/Test.sol";
import {DeployMarketplace} from "../script/DeployMarketplace.s.sol";
import {Marketplace} from "../src/Marketplace.sol";

contract TestMarketplace is Test {
    Marketplace public marketplace;
    DeployMarketplace public deployer;

    function setUp() public {
        deployer = new DeployMarketplace();
        marketplace = deployer.run();
    }

    function testInitialization() external {
        assertEq(address(marketplace), address(marketplace));
    }
}
