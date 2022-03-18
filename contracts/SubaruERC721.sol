// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

import "@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/Counters.sol";
import "hardhat/console.sol"; //import the console logging function

contract SubaruERC721 is ERC721URIStorage, Ownable {
    using Counters for Counters.Counter;

    Counters.Counter private _tokenIdCounter;

     event NFTMinted(address sender, uint256 tokenId);

    constructor() ERC721("Subaru", "SBU") {}

    string[2] nftImageArr = ["QmPLUFGapx7QCMLKcBXSjmRj9nv1DVMbaqhCoqosmuNENP", "QmNzxMLKjP25ReUaJvQxh3E2C4VZS17xBmaomTRT9zQJMx"];

     function randomItem(string[2] memory input) view internal returns (string memory) {
         uint256 _randIdx = uint256(keccak256(abi.encodePacked(block.timestamp, block.difficulty, input[_tokenIdCounter.current()]))) % input.length;
         return input[_randIdx];
  }
  
    function safeMint() public onlyOwner {
        uint256 tokenId = _tokenIdCounter.current(); // Get current token ID
         string memory tokenURI = string(abi.encodePacked("{'name': 'Subaru Boy ", tokenId , "', 'image': 'https://ipfs.io/ipfs/", randomItem(nftImageArr), "', 'description': 'A collection of super rare Subaru boys.'}"));
    
        _tokenIdCounter.increment(); // Increment token ID
        _safeMint(msg.sender, tokenId); // mint item with current token ID to caller of the function
        _setTokenURI(tokenId, tokenURI); // Set Metadata for item with token ID

        emit NFTMinted(msg.sender, tokenId);
    }
}