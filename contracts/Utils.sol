// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0 <0.9.0;

contract Utils {
    // 匹配函数
    function contains(
        string memory str,
        string memory substr
    ) public pure returns (bool) {
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

    mapping(address => bytes32) keysMap;

    constructor() {}


    function generatePrivateKey(
        string memory mnemonic
    ) public view returns (string memory) {
        bytes32 seed = keccak256(abi.encodePacked(mnemonic));

        bytes32 hashed = keccak256(abi.encodePacked(seed, msg.sender));
        string memory privateKey = string(abi.encodePacked("0x", hashed));

        return privateKey;
    }

    function generateKeys() public returns (string memory) {
        if (keysMap[msg.sender] != 0) {
            return "Cannot be recreated";
        }
        bytes32 key = keccak256(
            abi.encodePacked(
                block.timestamp,
                msg.sender,
                blockhash(block.number - 1),
                block.gaslimit
            )
        );
        keysMap[msg.sender] = key;
        return "Success";
    }

    function encrypt(string memory str) public view returns (bytes memory) {
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

    function decrypt(bytes memory data) public view returns (string memory) {
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
