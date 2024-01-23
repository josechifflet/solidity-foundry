// SPDX-License-Identifier: MIT
pragma solidity >=0.8.21 <0.9.0;

import { Test, console } from "forge-std/Test.sol";
import { PiggyBoxV1 } from "../src/PiggyBoxV1.sol";
import { IERC721 } from "@openzeppelin/contracts/token/ERC721/IERC721.sol";
import { ERC1967Proxy } from "@openzeppelin/contracts/proxy/ERC1967/ERC1967Proxy.sol";
import { UUPSUpgradeable } from "@openzeppelin/contracts-upgradeable/proxy/utils/UUPSUpgradeable.sol";

contract PiggyBoxV1Test is Test {
    PiggyBoxV1 piggyBoxV1;
    ERC1967Proxy proxy;

    address initialOwner = address(1);

    function setUp() public {
        piggyBoxV1 = new PiggyBoxV1();
        bytes memory initData = abi.encodeWithSelector(PiggyBoxV1(piggyBoxV1).initialize.selector, initialOwner, "baseURI/", "contractURI/");
        proxy = new ERC1967Proxy(address(piggyBoxV1), initData);
        piggyBoxV1 = PiggyBoxV1(address(proxy));
    }

    function testInitialize() public {
        assertEq(piggyBoxV1.owner(), initialOwner);
        assertEq(piggyBoxV1.contractURI(), "contractURI/");
        assertEq(piggyBoxV1.tokenURI(1), "baseURI/1.json");
        assertEq(piggyBoxV1.version(), 1);
    }

    function testFailReInitialize() public {
        piggyBoxV1.initialize(initialOwner, "newBaseURI/", "newContractURI/");
    }

    function testMint() public {
        address recipient = address(2);
        piggyBoxV1.mint(recipient);

        assertEq(piggyBoxV1.ownerOf(0), recipient);
        assertEq(piggyBoxV1.balanceOf(recipient), 1);
    }

    function testSetBaseTokenURI() public {
        vm.prank(initialOwner);
        piggyBoxV1.setBaseTokenURI("newBaseURI/");
        assertEq(piggyBoxV1.tokenURI(1), "newBaseURI/1.json");
    }

    function testFailSetBaseTokenURINotOwner() public {
        address notOwner = address(3);
        vm.prank(notOwner);
        piggyBoxV1.setBaseTokenURI("failURI/");
    }

    function testSetContractURI() public {
        vm.prank(initialOwner);
        piggyBoxV1.setContractURI("newContractURI/");
        assertEq(piggyBoxV1.contractURI(), "newContractURI/");
    }

    function testFailSetContractURINotOwner() public {
        address notOwner = address(4);
        vm.prank(notOwner);
        piggyBoxV1.setContractURI("failURI/");
    }

    function testSupportsInterface() public {
        assertTrue(piggyBoxV1.supportsInterface(type(IERC721).interfaceId));
    }

    function testGetTokenURI() public {
        assertEq(piggyBoxV1.tokenURI(1), "baseURI/1.json");
    }

    function testGetContractURI() public {
        assertEq(piggyBoxV1.contractURI(), "contractURI/");
    }
}
