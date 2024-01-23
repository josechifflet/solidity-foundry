// SPDX-License-Identifier: MIT
pragma solidity >=0.8.21 <0.9.0;

import { UUPSUpgradeable } from "@openzeppelin/contracts-upgradeable/proxy/utils/UUPSUpgradeable.sol";
import { ERC1967Proxy } from "@openzeppelin/contracts/proxy/ERC1967/ERC1967Proxy.sol";
import { Script } from "forge-std/Script.sol";
import { DevOpsTools } from "lib/foundry-devops/src/DevOpsTools.sol";
import { PiggyBoxV1 } from "../src/PiggyBoxV1.sol";
import { PiggyBoxV2 } from "../src/mock/PiggyBoxV2.sol";

contract UpgradePiggyBox is Script {
    function run() external returns (address) {
        address mostRecentlyDeployed = DevOpsTools.get_most_recent_deployment("ERC1967Proxy", block.chainid);
        vm.startBroadcast();
        PiggyBoxV2 newBox = new PiggyBoxV2();
        vm.stopBroadcast();
        address proxy = upgradePiggyBox(mostRecentlyDeployed, address(newBox));
        return proxy;
    }

    function upgradePiggyBox(address proxyAddress, address newImpl) public returns (address) {
        vm.startBroadcast();
        UUPSUpgradeable proxy = UUPSUpgradeable(proxyAddress);
        bytes memory initData = abi.encodeWithSelector(PiggyBoxV2(newImpl).initialize.selector, address(this), "baseURI/", "contractURI/");
        proxy.upgradeToAndCall(newImpl, initData);
        vm.stopBroadcast();
        return address(proxy);
    }
}
