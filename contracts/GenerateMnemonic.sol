// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0 <0.9.0;

contract GenerateMnemonic {

    function generateMnemonic() public view returns (string memory) {
        uint256 entropy = uint256(
            keccak256(abi.encodePacked(blockhash(block.number - 1), msg.sender))
        );
        bytes32[] memory words = new bytes32[](12);
        for (uint i = 0; i < 12; i++) {
            uint256 index = (entropy >> ((11 - i) * 11)) & 2047;
            bytes32 word = bytes32(index);
            words[i] = word;
        }
        string memory mnemonic = "";
        for (uint i = 0; i < words.length; i++) {
            mnemonic = string(
                abi.encodePacked(mnemonic, " ", string(abi.encodePacked(words[i])))
            );
        }
        return mnemonic;
    }
}
