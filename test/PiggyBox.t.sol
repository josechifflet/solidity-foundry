// SPDX-License-Identifier: UNLICENSED
pragma solidity >=0.8.21 <0.9.0;

import { PRBTest } from "prb/PRBTest.sol";
import { console2 } from "forge-std/console2.sol";
import { StdCheats } from "forge-std/StdCheats.sol";

import { PiggyBox } from "../src/PiggyBox.sol";


/// @dev If this is your first time with Forge, read this tutorial in the Foundry Book:
/// https://book.getfoundry.sh/forge/writing-tests
contract PiggyBoxTest is PRBTest, StdCheats {
    PiggyBox internal pb;

    address bob = address(1);
    address alice = address(2);

    /// @dev A function invoked before each test case is run.
    function setUp() public virtual {
        // Instantiate the contract-under-test.
        pb = new PiggyBox(msg.sender);
    }

    function test_nameIsPiggyBox() external {
        assertEq(pb.name(), "PiggyBox");
    }

    function test_ownerIsDeployer() external {
        assertEq(pb.owner(), address(this));
    }

    function test_IncreaseMintBalance() external {
        pb.increaseMintBalance(bob, 1);
        assertEq(pb.mintBalance(bob), 1);
    }
}
