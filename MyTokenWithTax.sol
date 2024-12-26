// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/math/SafeMath.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

contract AdjustableSupplyToken is IERC20, Ownable {
    using SafeMath for uint256;

    string public name = "AdjustableSupplyToken";
    string public symbol = "AST";
    uint8 public decimals = 18;
    uint256 public totalSupply;

    mapping(address => uint256) public balanceOf;
    mapping(address => mapping(address => uint256)) public allowance;

    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);
    event Mint(address indexed to, uint256 amount);
    event Burn(address indexed from, uint256 amount);

    constructor(uint256 initialSupply) public {
        totalSupply = initialSupply * (10 ** uint256(decimals));
        balanceOf[msg.sender] = totalSupply;
        emit Transfer(address(0), msg.sender, totalSupply);
    }

    function mint(uint256 amount) public onlyOwner {
        totalSupply = totalSupply.add(amount);
        balanceOf[owner()] = balanceOf[owner()].add(amount);
        emit Mint(owner(), amount);
        emit Transfer(address(0), owner(), amount);
    }

    function burn(uint256 amount) public onlyOwner {
        require(balanceOf[owner()] >= amount, "Insufficient balance to burn");
        totalSupply = totalSupply.sub(amount);
        balanceOf[owner()] = balanceOf[owner()].sub(amount);
        emit Burn(owner(), amount);
        emit Transfer(owner(), address(0), amount);
    }

    function adjustSupply(uint256 newSupply) external onlyOwner {
        require(newSupply > 0, "Invalid supply amount");
        if (newSupply > totalSupply) {
            mint(newSupply - totalSupply);
        } else {
            burn(totalSupply - newSupply);
        }
    }

    function transfer(address recipient, uint256 amount) external override returns (bool) {
        require(balanceOf[msg.sender] >= amount, "Insufficient balance");
        balanceOf[msg.sender] = balanceOf[msg.sender].sub(amount);
        balanceOf[recipient] = balanceOf[recipient].add(amount);
        emit Transfer(msg.sender, recipient, amount);
        return true;
    }

    function approve(address spender, uint256 amount) external override returns (bool) {
        allowance[msg.sender][spender] = amount;
        emit Approval(msg.sender, spender, amount);
        return true;
    }

    function transferFrom(address sender, address recipient, uint256 amount) external override returns (bool) {
        require(balanceOf[sender] >= amount, "Insufficient balance");
        require(allowance[sender][msg.sender] >= amount, "Allowance exceeded");
        balanceOf[sender] = balanceOf[sender].sub(amount);
        balanceOf[recipient] = balanceOf[recipient].add(amount);
        allowance[sender][msg.sender] = allowance[sender][msg.sender].sub(amount);
        emit Transfer(sender, recipient, amount);
        return true;
    }

    function allowance(address owner, address spender) external view override returns (uint256) {
        return allowance[owner][spender];
    }
}
