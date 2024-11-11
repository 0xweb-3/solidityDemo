// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {Initializable} from "@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol";
import "@openzeppelin/contracts-upgradeable/access/OwnableUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/access/AccessControlUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/utils/PausableUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/utils/ReentrancyGuardUpgradeable.sol";
import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

import "./interfaces/ITreasureManager.sol";

contract TreasureManager is
Initializable, // 初始化可升级合约
AccessControlUpgradeable, //权限控制
ReentrancyGuardUpgradeable, // 防止重入
OwnableUpgradeable, // 合约所有权
ITreasureManager {
    // 更新合约时 以下数据槽位不能乱
    using SafeERC20 for IERC20;

    // ETH地址
    address public constant ethAddress = address(0xEeeeeEeeeEeEeeEeEeEeeEEEeeeeEeeeeeeeEEeE);

    // 合约的管理员
    address public treasureManager;
    // 提取代币管理员
    address public withdrawManager;

    // 代币白名单
    address[] public tokenWhiteList;
    // token在合约中余额的维护
    mapping(address => uint256) public tokenBalances;
    // 用户代币数量的维护 用户=>代币=>数量
    mapping(address => mapping(address => uint256)) public userRewardAmounts;

    // 零地址错误
    error IsZeroAddress();

    // 存入token事件
    event DepositToken (
        address indexed tokenAddress,
        address indexed sender,
        uint256 amount
    );

    // 提取token事件
    event WithdrawToken (
        address indexed tokenAddress,
        address sender,
        address withdrawAddress,
        uint256 amount
    );

    // 记录奖励代币分配的信息事件
    event GrantRewardTokenAmount (
        address indexed tokenAddress,
        address granter,
        uint256 amount
    );

    //提现管理者地址的更新事件
    event WithdrawManagerUpdate (
        address indexed withdrawManager
    );

    modifier onlyTreasureManager() {
        require(msg.sender == address(treasureManager), "TreasureManager.onlyTreasureManager");
        _;
    }

    modifier onlyWithdrawManager() {
        require(msg.sender == address(withdrawManager), "TreasureManager.onlyWithdrawer");
        _;
    }

    // initializer 确保本函数只能被调用一次
    function initialize(address _initialOwner, address _treasureManager, address _withdrawManager) public initializer {
        treasureManager = _treasureManager;
        withdrawManager = _withdrawManager;
        _transferOwnership(_initialOwner); // 合约权限转移
    }

    // 接收ETH
    function depositEth() public payable  returns (bool) {
        tokenBalances[ethAddress] += msg.value;
        emit DepositToken(
            ethAddress,
            msg.sender,
            msg.value
        );
        return true;
    }

    receive() external payable {
        depositEth();
    }

    // 接收ERC-20
    function DepositErc20(IERC20 tokenAddress, uint256 amount) public returns (bool){
        tokenAddress.safeTransferFrom(msg.sender, address(this), amount);
        tokenBalances[address(tokenAddress)] += amount;
        emit DepositToken(address(tokenAddress), msg.sender, amount);
        return true;
    }

    // 为用户提交奖励
    function grantRewards(IERC20 tokenAddress, address granterAddress, uint256 amount) external onlyTreasureManager {
        require(address(tokenAddress) != address(0) && granterAddress != address(0), "Invalid address");
        userRewardAmounts[granterAddress][address(tokenAddress)] += amount;
        emit GrantRewardTokenAmount(address(tokenAddress), granterAddress, amount);
    }

    // cliam奖励的代币
    function cliamToken(IERC20 tokenAddress) external {
        require(address(tokenAddress) != address(0), "Invalid token address");
        uint256 rewardAmount = userRewardAmounts[msg.sender][address(tokenAddress)];
        require(rewardAmount > 0, "No reward available");
        if (address(tokenAddress) == ethAddress) {
            (bool success,) = msg.sender.call{value: rewardAmount}("");
            require(success, "ETH transfer failed");
        } else {
            IERC20(tokenAddress).safeTransfer(msg.sender, rewardAmount);
        }
        userRewardAmounts[msg.sender][address(tokenAddress)] = 0;
        tokenBalances[address(tokenAddress)] -= rewardAmount;
    }

    // cliam所有代币
    function cliamAllToken() external {
        for (uint256 i = 0; i < tokenWhiteList.length; i++) {
            address tokenAddress = tokenWhiteList[i]; // 被提现的代币
            uint256 rewardAmount = userRewardAmounts[address(msg.sender)][tokenAddress]; // 当前用户提现数量
            if (rewardAmount > 0) {
                if (tokenAddress == ethAddress) {
                    (bool success,) = msg.sender.call{value: rewardAmount}("");
                    require(success, "ETH transfer failed");
                } else {
                    IERC20(tokenAddress).safeTransfer(msg.sender, rewardAmount);
                }
                userRewardAmounts[msg.sender][address(tokenAddress)] = 0; // 奖励计数置0
                tokenBalances[tokenAddress] -= rewardAmount; // 减去总代币数量
            }
        }
    }

    // 提取ETH
    function WithdrawETH(address payable toAddress, uint256 amount) external onlyWithdrawManager returns (bool){
        require(address(this).balance >= amount, "Insufficient ETH balance in contract");
        (bool success,) = toAddress.call{value: amount}(""); // 支持向toAddress转账
        if (!success) {
            return false;
        }
        tokenBalances[ethAddress] -= amount;
        emit WithdrawToken(
            ethAddress,
            msg.sender,
            toAddress,
            amount
        );
        return true;
    }

    // 提取erc-20
    function WithdrawErc20(IERC20 tokenAddress, uint256 amount) external onlyWithdrawManager returns (bool){
        require(tokenBalances[address(tokenAddress)] >= amount, "Insufficient token balance in contract");
        IERC20(tokenAddress).safeTransfer(withdrawManager, amount);
        tokenBalances[address(tokenAddress)] -= amount;
        emit WithdrawToken(
            address(tokenAddress),
            address(msg.sender),
            withdrawManager,
            amount
        );
        return true;
    }

    // 白名单
    function setTokenWhiteList(address tokenAddress) external onlyTreasureManager {
        if (tokenAddress == address(0)) {
            revert IsZeroAddress();
        }
        tokenWhiteList.push(tokenAddress);
    }

    function getTokenWhiteList() external view returns (address[] memory){
        return tokenWhiteList;
    }

    // 设置提现管理员
    function setWithdrawManager(address _withdrawManager) external onlyOwner {
        withdrawManager = _withdrawManager;
        emit WithdrawManagerUpdate(
            withdrawManager
        );
    }

    function queryRewards(address _tokenAddress) external view returns (uint256){
        return userRewardAmounts[msg.sender][_tokenAddress];
    }

}
