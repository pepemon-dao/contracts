pragma solidity ^0.6.0;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/token/ERC20/SafeERC20.sol";
import "@openzeppelin/contracts/math/SafeMath.sol";

contract PepemonToken is ERC20 {

    using SafeERC20 for IERC20;
    using SafeMath for uint256;

    address owner;

    modifier _onlyOwner() {
        require(msg.sender == owner);
        _;
    }

    constructor() public payable ERC20("Pepeball", "PPBLZ") {
        owner = msg.sender;
        uint256 supply = 14000;
        _mint(msg.sender, supply.mul(10 ** 18));
    }
}
