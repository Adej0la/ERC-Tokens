// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/Counters.sol";
import "hardhat/console.sol"; //import the console logging function


contract SubaruERC20 is ERC20, Ownable {
    address private msgSender;
    uint private _supply = 1000000;
    uint public constant tokensPerEth = 1000;     // The amount of ether required to purchase one token


    receive() external payable {}      // Function to receive Ether. msg.data must be empty


    fallback() external payable {}    // Fallback function is called when msg.data is not empty


    event Bought(address _buyer, uint _amountOfETH, uint _amountOfToken);
    event Sold(address _seller, uint _amountOfToken,  uint _amountOfETH);
    
    constructor() ERC20("Subaru", "SBU") {
        msgSender = msg.sender;
        _mint(msg.sender, _supply * 10 ** decimals());        // Initializes a total capped supply of 1,000,000 tokens on deployment

    }

    uint256 private _depleted = _supply - balanceOf(msgSender);

    function topUp() public onlyOwner {
        _mint(msgSender, _depleted);        // Replenishes the total supply of tokens to the initial capped supply

    }

  // This allows users to buy tokens
  function buy() 
        payable
        public
        {
     // Ensures that the eth value sent to the contract is greater than 0
        require(msg.value > 0, "You need to send some Ether");         
        
    // The eth amount of the total tokens to be bought
        uint256 buyAmount = msg.value * tokensPerEth;        

    // Requires that token owner has enough tokens to sell to user
        require(balanceOf(msgSender) >= buyAmount);

    // Transfer tokens to the caller of this function
       _transfer(msgSender, msg.sender, buyAmount);        

    //    require(sent, "Failed to transfer token to user");
        
        emit Bought(msg.sender, msg.value, buyAmount);        // Emit the event

        (bool sent,) = payable(msgSender).call{value: msg.value}("");
        require(sent, "failed to receive ETH from the user");

    }

    function sell(uint _amount) public {
        require(_amount > 0, "You need to sell at least 1 token");

        uint256 userBalance = balanceOf(msg.sender);
        require(userBalance >= _amount, "your balance is lower than the amount of tokens you want to sell");        // require the user's balance to be more than the amount of tokens to be sold

        uint256 transferAmountEth = _amount / tokensPerEth;        // calculate the ether equivalent of the amount to be sold

        uint256 ownerBalance = address(this).balance;        // The eth (not token) balance of the contract (or the vendor)

        require(ownerBalance >= transferAmountEth, "Vendor has an insuficient balance and cannot accept the sell request");        // Ensure that the spender (that is the vendor) can cover the amount to be sent 


        (bool sent) = transferFrom(msg.sender, address(this), _amount);
        require(sent, "Failed to transfer tokens from user to the vendor");        // transfer tokens from the user to the contract


        (sent,) = msg.sender.call{value: transferAmountEth}("");
        require(sent, "failed to send ETH to the user");

        emit Sold(msg.sender, _amount, transferAmountEth);
    }
}

