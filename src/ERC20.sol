// SPDX-License-Identifier: UNLICENSED
pragma solidity >=0.8.21 <0.9.0;

import { ERC20 } from "solmate/tokens/ERC20.sol";

contract ERC20Token is ERC20("Vct", "VCT", 18) {
    constructor() {
        // 1 million tokens
        _mint(msg.sender, 1_000_000 * (10 ** 18));
    }
}
