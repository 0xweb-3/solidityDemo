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

    function setUp() public {}

    function run() public {
        uint256 depolyerPrivateKey = vm.envUint("PRIVATE_KEY");
        address depolyerAddress = vm.addr(depolyerPrivateKey);

        proxyTreasureManager = ""; // 部署的工厂合约

        vm.startBroadcast(depolyerPrivateKey);
        deployAddmin = ProxyAdmin(depolyerAddress);
        console2.log("the deploy address:", address(deployAddmin));

        TreasureManager treasureManagerV2 = new TreasureManager();
        console.log("treasureManagerV2:", address(treasureManagerV2));

        // 进行合约的升级
        ProxyAdmin(deployAddmin).upgradeAndCall(ITransparentUpgradeableProxy(proxyTreasureManager), address(treasureManagerV2), bytes(""));

        vm.stopBroadcast();
    }
}



