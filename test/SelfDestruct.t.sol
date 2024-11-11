// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {Test, console2} from "forge-std/Test.sol";
import {SelfDestruct} from "../src/SelfDestruct.sol";

contract SelfDestructTest is Test {
    SelfDestruct public selfDestruct;

    function setUp() public {
        selfDestruct = new SelfDestruct();
    }

    function test_setData() public {
        selfDestruct.setData(1024);
        assertEq(selfDestruct.data(), 1024);
    }
}
