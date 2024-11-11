// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

interface ITreasureManager {
    // 接收ETH
    function depositEth() external payable returns (bool);
    // 接受ERC-20充值
    function DepositErc20(IERC20 tokenAddress, uint256 amount) external returns (bool);

    // 提现ETH
    function WithdrawETH(address payable toAddress, uint256 amount) external returns (bool);
    // 提现ERC-20
    function WithdrawErc20(IERC20 tokenAddress, uint256 amount) external returns (bool);

    // 奖励的资金
    function grantRewards(IERC20 tokenAddress, address granterAddress, uint256 amount) external;
    function queryRewards(address _tokenAddress) external view returns (uint256);

    // cliam代币
    function cliamToken(IERC20 tokenAddress) external;
    function cliamAllToken() external;

    // 白名单
    function setTokenWhiteList(address tokenAddress) external;
    function getTokenWhiteList() external view returns (address[] memory);

    // 设置提现管理员
    function setWithdrawManager(address _withdrawManager) external;

}