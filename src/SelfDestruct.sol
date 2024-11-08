pragma solidity ^0.8.13;

import {Initializable} from "@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol";
import "@openzeppelin/contracts-upgradeable/access/OwnableUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/access/AccessControlUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/utils/PausableUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/utils/ReentrancyGuardUpgradeable.sol";
import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

contract SelfDestruct is Initializable, AccessControlUpgradeable, ReentrancyGuardUpgradeable, OwnableUpgradeable {
    address payable public admin;
    uint256 public data;

    modifier onlyAdmin() {
        require(msg.sender == admin, "only owner call");
        _;
    }

    receive() external payable {}

    function initialize(address _initialOwner, address _admin) public initializer {
        _transferOwnership(_initialOwner);
        admin = payable(_admin);
        data = 1000;
    }

    function setData(uint256 _data) public {
        data = _data;
    }

    constructor(){
        admin = payable(msg.sender);
    }

    function close() public onlyAdmin() {
        selfdestruct(admin);
    }
}
