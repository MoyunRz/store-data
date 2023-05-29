// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0 <0.9.0;

import "../node_modules/@openzeppelin/contracts/access/Ownable.sol";

contract Mnemonics is Ownable {

    mapping(uint256=>string) private wordsMap;

    uint256 private len = 0;
   
    function addWords(string[] memory _words) public onlyOwner {

        uint256 index = 0;
        if (len!=0){
            index = len-1;
        }
        for(uint256 i= 0;i < _words.length;i++){
            wordsMap[len] = _words[i];
            len++;
        }
    }
    
    function getLen() public view onlyOwner returns(uint256)  {
        return len;
    }

    function getRandom() public view returns (uint256 ) {
       return uint256(keccak256(abi.encodePacked(block.timestamp, block.prevrandao, msg.sender)));
    }

    function generateMnemonic(uint256 lenght) public view returns (string[] memory,uint256[] memory) {
        uint256 index = getRandom();
        string[] memory words = new string[](lenght);
        uint256[] memory indexs = new uint256[](lenght);
        for (uint i = 0; i < 12; i++) {
            uint256 wordIndex = index % len;
            words[i] = wordsMap[wordIndex];
            index /= len;
            indexs[i] = wordIndex;
        }
        return (words,indexs);
    }

}