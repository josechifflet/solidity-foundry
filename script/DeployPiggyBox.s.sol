// SPDX-License-Identifier: MIT
pragma solidity >=0.8.21 <0.9.0;

import { ERC1967Proxy } from "@openzeppelin/contracts/proxy/ERC1967/ERC1967Proxy.sol";
import { PiggyBoxV1 } from "../src/PiggyBoxV1.sol";
import { Script } from "forge-std/Script.sol";

/// @dev See the Solidity Scripting tutorial: https://book.getfoundry.sh/tutorials/solidity-scripting
contract DeployPiggyBox is Script {
    function run() external returns (address) {
        address proxy = deploy();
        return proxy;
    }

    function deploy() public returns (address) {
        string memory seedPhrase = vm.readFile(".secret");
        uint256 privateKey = vm.deriveKey(seedPhrase, 0);

        vm.startBroadcast(privateKey);
        PiggyBoxV1 piggyBoxV1 = new PiggyBoxV1();
        bytes memory initData =
            abi.encodeWithSelector(PiggyBoxV1(piggyBoxV1).initialize.selector, address(this), "baseURI/", "contractURI/");
        ERC1967Proxy proxy = new ERC1967Proxy(address(piggyBoxV1), initData);
        vm.stopBroadcast();
        return address(proxy);
    }
}
