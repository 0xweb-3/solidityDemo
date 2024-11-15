// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import "@openzeppelin/contracts/proxy/transparent/ProxyAdmin.sol";
import "@openzeppelin/contracts/proxy/transparent/TransparentUpgradeableProxy.sol";

import {Script, console2} from "forge-std/Script.sol";
import {UUPSContractV1} from "../src/UUPSContractV1.sol";

contract UUPSContractV1Script is Script {
    address public proxy = 0xEd63674ebAEd5D5fe567b41Bab2ac16e2f9c1386;

    function setUp() public {}

    function run() public {
        uint256 depolyerPrivateKey = vm.envUint("PRIVATE_KEY");
        address depolyerAddress = vm.addr(depolyerPrivateKey);

        vm.startBroadcast(depolyerPrivateKey);

        Upgrades.upgradeProxy(address(proxy), "UUPSContractV2.sol:UUPSContractV2", "", deployerAddress);
        (bool successful,) = address(proxy).call(abi.encodeWithSelector(UUPSContractV2.incrementValue.selector));
        console.log("incrementValue success:", successful);

        vm.stopBroadcast();
    }
}