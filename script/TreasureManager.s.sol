// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import "@openzeppelin/contracts/proxy/transparent/ProxyAdmin.sol";
import "@openzeppelin/contracts/proxy/transparent/TransparentUpgradeableProxy.sol";

import {Script, console2} from "forge-std/Script.sol";
import {TreasureManager} from "../src/TreasureManager.sol";

/*
forge script script/TreasureManager.s.sol:TreasureManagerScript --rpc-url $ETH_RPC_URL --private-key $PRIVATE_KEY  --broadcast -vvvv
*/
// 使用透明代理部署合约
contract TreasureManagerScript is Script {
    ProxyAdmin public deployAddmin; // 部署使用的管理员
    TreasureManager public treasureManager;

    function setUp() public {}

    function run() public {
        uint256 depolyerPrivateKey = vm.envUint("PRIVATE_KEY");
        address depolyerAddress = vm.addr(depolyerPrivateKey);

        vm.startBroadcast(depolyerPrivateKey);
        deployAddmin = ProxyAdmin(depolyerAddress);
        console2.log("the deploy address:", address(deployAddmin));

        treasureManager = new TreasureManager();
        console2.log("the treasureManager contract address:", address(treasureManager));
        TransparentUpgradeableProxy proxyTreasureManager = new TransparentUpgradeableProxy(
            address(treasureManager), // 被代理合约
            address(deployAddmin), // 超级管理员
            abi.encodeWithSelector(treasureManager.initialize.selector, depolyerAddress, depolyerAddress, depolyerAddress)
//            bytes("") // 没有init时
        );

        console2.log("TreasureManager contract address:", address(proxyTreasureManager));

        vm.stopBroadcast();
    }
}



