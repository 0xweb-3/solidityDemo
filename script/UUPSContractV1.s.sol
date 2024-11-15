// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import "@openzeppelin/contracts/proxy/transparent/ProxyAdmin.sol";
import "@openzeppelin/contracts/proxy/transparent/TransparentUpgradeableProxy.sol";

import {Script, console2} from "forge-std/Script.sol";
import {UUPSContractV1} from "../src/UUPSContractV1.sol";

contract UUPSContractV1Script is Script {
    function setUp() public {}

    function run() public {
        uint256 depolyerPrivateKey = vm.envUint("PRIVATE_KEY");
        address depolyerAddress = vm.addr(depolyerPrivateKey);

        vm.startBroadcast(depolyerPrivateKey);

        UUPSContractV1 implementation = new UUPSContractV1();
        console.log("UUPSContractV1 address:", address(implementation));
        bytes memory data = abi.encodeCall(implementation.initialize, deployerAddress);
        ERC1967Proxy proxy = new ERC1967Proxy(address(implementation), data);

        vm.stopBroadcast();

        console.log("UUPS Proxy Address:", address(proxy));
    }
}