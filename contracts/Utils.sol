// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0 <0.9.0;


contract Utils {
    
    mapping(address => bytes32) private keysMap;
    mapping(address => uint256[]) private userIndexMap;

    constructor() {}
    // 匹配函数
    function contains(
        string memory str,
        string memory substr
    ) internal pure returns (bool) {
        bytes memory bStr = bytes(str);
        bytes memory bSubstr = bytes(substr);
        if (bSubstr.length > bStr.length) {
            return false;
        } else if (bSubstr.length == bStr.length) {
            return keccak256(bStr) == keccak256(bSubstr);
        } else {
            for (uint i = 0; i < bStr.length - bSubstr.length + 1; i++) {
                bool found = true;
                for (uint j = 0; j < bSubstr.length; j++) {
                    if (bStr[i + j] != bSubstr[j]) {
                        found = false;
                        break;
                    }
                }
                if (found) {
                    return true;
                }
            }
            return false;
        }
    }

    function _calculateMD5(string memory _text) internal pure returns (bytes32) {
        bytes32 hash = keccak256(bytes(_text));
        return hash;
    }

    function _encrypt(string memory str) internal view returns (bytes memory) {
        if (keysMap[msg.sender] == 0) {
            return bytes("Please create a key");
        }
        bytes memory iv = bytes("0123456789abcdef");
        bytes memory plaintext = bytes(str);
        bytes memory ciphertext = new bytes(plaintext.length);
        bytes32 key = keysMap[msg.sender];
        for (uint i = 0; i < plaintext.length; i++) {
            ciphertext[i] = plaintext[i] ^ key[i % 32];
        }
        return abi.encodePacked(iv, ciphertext);
    }

    function _decrypt(bytes memory data) internal view returns (string memory) {
        if (keysMap[msg.sender] == 0) {
            return "Please create a key";
        }
        bytes memory iv = new bytes(16);
        bytes memory ciphertext = new bytes(data.length - 16);

        for (uint i = 0; i < 16; i++) {
            iv[i] = data[i];
        }
        bytes32 key = keysMap[msg.sender];
        for (uint i = 16; i < data.length; i++) {
            ciphertext[i - 16] = data[i] ^ key[(i - 16) % 32];
        }
        return string(ciphertext);
    }
}
 