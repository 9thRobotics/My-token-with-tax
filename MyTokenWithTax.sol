// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract MyTokenWithTax {
    string public name = "MyTokenWithTax";
    string public symbol = "MTKT";
    uint8 public decimals = 18;
    uint256 public totalSupply = 1000000 * (10 ** uint256(decimals));
    address public owner;
    address public treasuryWallet;

    uint256 public taxRate = 2; // 2% tax

    mapping(address => uint256) public balanceOf;

    event Transfer(address indexed from, address indexed to, uint256 value);

    constructor(address _treasuryWallet) {
        owner = msg.sender;
        treasuryWallet = _treasuryWallet;
        balanceOf[msg.sender] = totalSupply;
    }

    function transfer(address _to, uint256 _value) public returns (bool success) {
        require(balanceOf[msg.sender] >= _value, "Insufficient balance");

        uint256 tax = (_value * taxRate) / 100; // Calculate tax
        uint256 amountAfterTax = _value - tax;

        balanceOf[msg.sender] -= _value; // Deduct full amount from sender
        balanceOf[_to] += amountAfterTax; // Send the remaining amount to recipient
        balanceOf[treasuryWallet] += tax; // Send tax to treasury wallet

        emit Transfer(msg.sender, _to, amountAfterTax);
        emit Transfer(msg.sender, treasuryWallet, tax);
        return true;
    }
}
