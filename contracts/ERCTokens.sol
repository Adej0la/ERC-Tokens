// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/Counters.sol";
import "hardhat/console.sol"; //import the console logging function


contract SubaruERC20 is ERC20, Ownable {
    address payable private msgSender = payable(msg.sender);
    uint private _supply = 1000000;
    uint public constant tokensPerEth = 1000;     // The amount of ether required to purchase one token


    receive() external payable {}      // Function to receive Ether. msg.data must be empty


    fallback() external payable {}    // Fallback function is called when msg.data is not empty


    event Bought(address _buyer, uint _amountOfETH, uint _amountOfToken);
    
    constructor() ERC20("Subaru", "SBU") {
        _mint(msgSender, _supply * 10 ** decimals());        // Initializes a total capped supply of 1,000,000 tokens on deployment

    }

    uint256 private _depleted = _supply - balanceOf(msgSender);

    function topUp() public onlyOwner {
        _mint(msgSender, _depleted);        // Replenishes the total supply of tokens to the initial capped supply

    }

  function buy() payable public returns (uint256 tokenAmount) {
        require(msg.value > 0, "You need to send some Ether");         // Ensures that the eth value included in func is greater than 0


        uint256 buyAmount = msg.value * tokensPerEth;        // The eth amount of the total tokens to be bought


        uint256 contractBalance = balanceOf(address(this));
        require(buyAmount <= contractBalance, "Not enough tokens in the reserve");

       (bool sent) =  transfer(msgSender, buyAmount);        // Transfer tokens to the sender of this function

       require(sent, "Failed to transfer token to user");
        
        emit Bought(msg.sender, msg.value, buyAmount);        // Emit the event


        return buyAmount;
    }

    function sell(uint _amount) public {
        require(_amount > 0, "You need to sell at least 1 token");

        uint256 userBalance = balanceOf(msg.sender);
        require(userBalance >= _amount, "your balance is lower than the amount of tokens you want to sell");        // require the user's balance to be more than the amount of tokens to be sold


        uint256 transferAmountEth = _amount / tokensPerEth;        // calculate the ether equivalent of the amount to be sold


        uint256 allowance = allowance(msgSender, address(this));        // the amount of tokens the contract is allowed to have access to on behalf of the owner


        uint256 spenderBalance = address(this).balance;        // The balance of the contract (or the vendor)


        require(allowance >= _amount, "Increase the token allowance");
        require(spenderBalance >= transferAmountEth, "Vendor has an insuficient balance and cannot accept the sell request");        // Ensure that the spender (that is the vendor) can cover the amount to be sent 


        (bool sent) = transferFrom(msgSender, address(this), _amount);
        require(sent, "Failed to transfer tokens from user to the vendor");        // transfer tokens from the user to the contract


        (sent,) = msgSender.call{value: transferAmountEth}("");
        require(sent, "failed to send ETH to the user");
    }
}

contract SubaruERC721 is ERC721URIStorage, Ownable {
    using Counters for Counters.Counter;

    Counters.Counter private _tokenIdCounter;

     event NewEpicNFTMinted(address sender, uint256 tokenId);

    constructor() ERC721("Subaru", "SBU") {}

    function safeMint() public onlyOwner {
        uint256 tokenId = _tokenIdCounter.current(); // Get current token ID
        string memory tokenName;
        string memory tokenImageLink;
         string memory tokenURI = string(abi.encodePacked("{'name': ", tokenName, ", 'description': 'A collection of super rare Subaru boys.' , 'image': ", tokenImageLink, "}"));
    
        _tokenIdCounter.increment(); // Increment token ID
        _safeMint(msg.sender, tokenId); // mint item with current token ID to caller of the function
        _setTokenURI(tokenId, tokenURI); // Set Metadata for item with token ID

        emit NewEpicNFTMinted(msg.sender, tokenId);
    }
}