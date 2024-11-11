// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import "@openzeppelin/contracts/proxy/transparent/ProxyAdmin.sol";
import "@openzeppelin/contracts/proxy/transparent/TransparentUpgradeableProxy.sol";

import {Script, console2} from "forge-std/Script.sol";
import {SelfDestruct} from "../src/SelfDestruct.sol";


/*
forge script script/SelfDestruct.s.sol:SelfDestructScript --rpc-url $ETH_RPC_URL --private-key $PRIVATE_KEY  --broadcast -vvvv
*/
// 使用透明代理部署合约
contract SelfDestructScript is Script{
    ProxyAdmin public deployAddmin; // 部署使用的管理员
    SelfDestruct public selfDestuct;

    function setUp() public {}

    function run () public {
        uint256 depolyerPrivateKey = vm.envUint("PRIVATE_KEY");
        address depolyerAddress = vm.addr(depolyerPrivateKey);

        vm.startBroadcast(depolyerPrivateKey);
        deployAddmin = ProxyAdmin(depolyerAddress);
        console2.log("the deploy address:", address(deployAddmin));
        selfDestuct = new SelfDestruct();
        TransparentUpgradeableProxy proxySelfDestuct = new TransparentUpgradeableProxy(
            address(selfDestuct), // 被代理合约
            address(deployAddmin), // 超级管理员
            abi.encodeWithSelector(SelfDestruct.initialize.selector, depolyerAddress, depolyerAddress)
//            bytes("") // 没有init时
        );

        console2.log("SelfDestruct contract address:", address(proxySelfDestuct));

        vm.stopBroadcast();
    }
}


//the deploy address: 0x43b8E86fDdE29197988C63367c446Ff330f1De4f
//SelfDestruct contract address: 0x70E0152Ba46D59BCaB31eDf1BC86A87Ba331e6f2




