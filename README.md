# solidity案例

## 使用

### forge使用

* 初始化`forge init`

```shell
forge build # 合约编译
forge test # 运行测试
forge create path/to/Contract.sol:ContractName --rpc-url <YOUR_RPC_URL> --private-key <YOUR_PRIVATE_KEY> # 部署合约
forge test -vvvv
```

```shell
# 代码部署到网络上
forge script script/SelfDestruct.s.sol:SelfDestructScript --rpc-url $ETH_RPC_URL --private-key $PRIVATE_KEY  --broadcast -vvvv
# 验证代码并发布到区块浏览器上
forge verify-contract --chain-id <chain_id> --etherscan-api-key <your_etherscan_api_key> <contract_address> <path_to_source_code>

forge verify-contract --chain-id 11155111 --etherscan-api-key $ETHERSCAN_API_KEY 0x2c4d7e88821B6e90ae5c6ddbA08f5D1d74cc5e51 ./cache/solidity-files-cache.json

```
参数说明：
* <chain_id>：链的 ID，例如 Ethereum 为 1，Sepolia 为 11155111。
* <contract_address>：合约的部署地址。
* <path_to_source_code>：合约源文件的路径。


### Cast 使用

```shell
cast balance <ACCOUNT_ADDRESS> --rpc-url <YOUR_RPC_URL> # 查询账户余额
cast send <TO_ADDRESS> --value <AMOUNT_IN_WEI> --rpc-url <YOUR_RPC_URL> --private-key <YOUR_PRIVATE_KEY> # 发送交易
cast call <CONTRACT_ADDRESS> "functionName()" --rpc-url <YOUR_RPC_URL> # 调用合约函数
```

### 安装库

```shell
forge install OpenZeppelin/openzeppelin-contracts-upgradeable  --no-commit # 透明代理
forge install OpenZeppelin/openzeppelin-contracts  --no-commit
forge install foundry-rs/forge-std --no-commit
 
forge remappings
forge remappings > remappings.txt
```







