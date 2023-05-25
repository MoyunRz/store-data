// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0 <0.9.0;
import "./Crypts.sol";

contract ChatStorage is Crypts {
    // 构建文件内容存储结构体
    struct ChatInfo {
        string ps;
        string content;
        uint256 timestamp;
    }

    // uint256 记录键值，减少大面积查询，避免耽误查询时间
    mapping(address => uint256[]) timelist;
    // 用于存储数据的映射
    // uint256 是时间戳，如：1684832014
    mapping(address => mapping(uint256 => ChatInfo)) chats;

    event ChatStored(string ps, bytes content, uint256 timestamp);

    // 初始化函数
    constructor() {}

    // 存储文件内容
    function storeChat(string memory ps, string memory content) public {
        generateKeys();
        bytes memory encrypt_content = encrypt(content);
        uint256 timestamp = block.timestamp; //获取当前区块链时间戳
        address caller = msg.sender; //获取调用者地址
        chats[caller][timestamp] = ChatInfo({
            ps: ps,
            content: string(encrypt_content),
            timestamp: timestamp
        });
        timelist[caller].push(timestamp);
        emit ChatStored(ps, encrypt_content, timestamp);
    }

    // 查询
    function FindChatStorage(
        string memory ps,
        uint256 startTime,
        uint256 endTime
    ) public view returns (ChatInfo[] memory) {
        uint256[] memory kl = getTimelist(msg.sender);
        if (startTime < endTime && endTime > 0) {
            kl = getListIndex(startTime, endTime);
            if (kl.length == 0) {
                return new ChatInfo[](0);
            }
        }
        // 获取匹配的数组
        uint256[] memory res = filterListBySubStr(ps, kl);
        uint256 j = 0;
        ChatInfo[] memory result = new ChatInfo[](res.length);

        for (uint256 i = res.length - 1; j < res.length; ) {
            result[j] = newMapChatInfo(res[i]);
            j++;
            if (i==0) {
               return result;
            }else{
                i--;
            }
        }
        return result;
    }

    // 根据时间 名字查询
    function FindChatHistory(
        string memory fileName,
        uint256 startTime,
        uint256 endTime,
        uint256 startIndex,
        uint256 size
    ) public view returns (ChatInfo[] memory) {
        // 获取该地址有的存储
        uint256[] memory kl = getTimelist(msg.sender);
        // 根据时间遍历查询key值
        if (startTime < endTime && endTime > 0) {
            kl = getListIndex(startTime, endTime);
            if (kl.length == 0) {
                return new ChatInfo[](0);
            }
        }
        // 获取匹配的数组
        uint256[] memory res = filterListBySubStr(fileName, kl);
        uint256 j = 0;
        ChatInfo[] memory result;

        uint256 len = res.length - startIndex;
        if (len <= 0) {
            return new ChatInfo[](0);
        }
        // 先根据原有数组长度和起始位置判断是否够预计需要查询的长度
        if (len > size && size > 0) {
            result = new ChatInfo[](size);
        } else {
            result = new ChatInfo[](len);
        }
        // 开始遍历赋值
        for (uint256 i = len - 1; j < res.length; ) {
            result[j] = newMapChatInfo(res[i]);
            if (j == result.length - 1) {
                return result;
            }
            j++;
            if (i == 0) {
                return result;
            } else {
                i--;
            }
        }
        return result;
    }

    // 根据时间戳获取文件内容
    function newMapChatInfo(uint256 tsp) public view returns (ChatInfo memory) {
        ChatInfo memory chat = chats[msg.sender][tsp];
        return ChatInfo({
             ps:chat.ps,
             content: decrypt(bytes(chat.content)),
             timestamp:chat.timestamp
        });
    }
    // 数组过滤
    function filterListBySubStr(
        string memory subName,
        uint256[] memory kl
    ) internal view returns (uint256[] memory) {
        uint256 klen = kl.length;
        if (bytes(subName).length == 0 || klen == 0) {
            return kl;
        }
        uint256 len = 0;
        uint256[] memory buf = new uint256[](klen);
        for (uint256 i = 0; i < klen; i++) {
            uint256 tsp = kl[i];
            bool isMatched = contains(chats[msg.sender][tsp].ps, subName);
            if (isMatched) {
                buf[len] = tsp;
                len++;
            }
        }
        uint256[] memory res = new uint256[](len);
        if (len != 0) {
            for (uint256 i = 0; i < len; i++) {
                res[i] = buf[i];
            }
        }
        return res;
    }

    function getListIndex(
        uint256 startTime,
        uint256 endTime
    ) internal view returns (uint256[] memory) {
        uint256 length = 0;
        uint256 end = 0;
        uint256[] memory kl = getTimelist(msg.sender);
        uint256 klen = kl.length;
        for (uint256 i = 0; i < klen; i++) {
            if (kl[i] >= startTime && kl[i] <= endTime) {
                length++;
                end = i;
            }
        }

        uint256[] memory result = new uint256[](length);
        if (length != 0) {
            end += 1;
            uint256 j = 0;
            for (uint256 i = end - length; i < end; i++) {
                result[j++] = kl[i];
            }
            return result;
        }
        return result;
    }

    function getTimelist(address key) internal view returns (uint256[] memory) {
        return timelist[key];
    }

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
