// SPDX-License-Identifier: MIT
pragma solidity >=0.8.21 <0.9.0;

import { Test, console } from "forge-std/Test.sol";
import { PiggyBoxV1 } from "../src/PiggyBoxV1.sol";
import { PiggyBoxV2 } from "../src/mock/PiggyBoxV2.sol";
import { IERC721 } from "@openzeppelin/contracts/token/ERC721/IERC721.sol";
import { ERC1967Proxy } from "@openzeppelin/contracts/proxy/ERC1967/ERC1967Proxy.sol";
import { UUPSUpgradeable } from "@openzeppelin/contracts-upgradeable/proxy/utils/UUPSUpgradeable.sol";

contract PiggyBoxV1Test is Test {
    PiggyBoxV1 piggyBoxV1;
    PiggyBoxV2 piggyBoxV2;
    ERC1967Proxy proxy;

    address initialOwner = address(1);

    function setUp() public {
        piggyBoxV1 = new PiggyBoxV1();
        bytes memory initData = abi.encodeWithSelector(PiggyBoxV1(piggyBoxV1).initialize.selector, initialOwner, "baseURI/", "contractURI/");
        proxy = new ERC1967Proxy(address(piggyBoxV1), initData);
        piggyBoxV1 = PiggyBoxV1(address(proxy));
    }

    function testUpgradeToV2() public {
        // Deploy the new version of the contract
        PiggyBoxV2 newImplementation = new PiggyBoxV2();

        // The address with permission to perform the upgrade
        address authorizedUpgrader = initialOwner; // adjust this as per your contract's authorization logic

        // Simulate the call from the authorized upgrader
        vm.prank(authorizedUpgrader);

        // Perform the upgrade
        UUPSUpgradeable(address(proxy)).upgradeToAndCall(address(newImplementation), new bytes(0));

        // Cast the proxy to the new implementation
        piggyBoxV2 = PiggyBoxV2(address(proxy));

        // Verify the upgrade (e.g., through a version number or new functionality)
        assertEq(piggyBoxV2.owner(), initialOwner);
        assertEq(piggyBoxV2.contractURI(), "contractURI/");
        assertEq(piggyBoxV2.tokenURI(1), "baseURI/1.json");
        assertEq(piggyBoxV2.version(), 2);

        vm.prank(authorizedUpgrader);

        piggyBoxV2.postUpgradeInitialization();

        assertEq(piggyBoxV2.getNextTokenId(), 1000);
    }
}
