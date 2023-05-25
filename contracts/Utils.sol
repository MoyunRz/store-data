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
}