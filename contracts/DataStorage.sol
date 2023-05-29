// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0 <0.9.0;

import "./Utils.sol";
import "./Storages.sol";

contract DataStorage is Utils,Storages  {
   
    event FileStored(
        string fileName,
        string fileType,
        bytes fileContent,
        uint256 timestamp
    );
    // 初始化函数
    constructor() {}

    // 存储文件内容
    function storeFile(
        string memory name,
        string memory dataType,
        string memory dataContent
    ) public {
        generateKeys();
        bytes memory content = encrypt(dataContent);
        uint256 timestamp = block.timestamp; //获取当前区块链时间戳
        StorageInfo memory info =  StorageInfo({
            name: name,
            dataType: dataType,
            content: string(content),
            timestamp: timestamp
        });
        setStorage(info);
        emit FileStored(name, dataType, content, timestamp);
    }

    function FindFileStorage(
        string memory fileName,
        uint256 startTime,
        uint256 endTime
    ) public view returns (StorageInfo[] memory) {
        uint256[] memory kl = getTimelist(msg.sender);
        if (startTime < endTime && endTime > 0) {
            kl = getListIndex(startTime, endTime);
            if (kl.length == 0) {
                return new StorageInfo[](0);
            }
        }
        // 获取匹配的数组
        uint256[] memory res = filterListBySubStr(fileName, kl);
        if (res.length == 0) {
            return new StorageInfo[](0);
        }
        uint256 j = 0;
        StorageInfo[] memory result = new StorageInfo[](res.length);
        for (uint256 i = res.length - 1; j < res.length; ) {
            result[j] = newMapStorageInfo(res[i]);
            j++;
            if (i == 0) {
                return result;
            } else {
                i--;
            }
        }
        return result;
    }

    // 根据时间 名字查询
    function FindFileHistory(
        string memory fileName,
        uint256 startTime,
        uint256 endTime,
        uint256 startIndex,
        uint256 size
    ) public view returns (StorageInfo[] memory) {
        // 获取该地址有的存储
        uint256[] memory kl = getTimelist(msg.sender);
        // 根据时间遍历查询key值
        if (startTime < endTime && endTime > 0) {
            kl = getListIndex(startTime, endTime);
            if (kl.length == 0) {
                return new StorageInfo[](0);
            }
        }
        // 获取匹配的数组
        uint256[] memory res = filterListBySubStr(fileName, kl);
        uint256 j = 0;
        StorageInfo[] memory result;

        uint256 len = res.length - startIndex;
        if (len <= 0) {
            return new StorageInfo[](0);
        }
        // 先根据原有数组长度和起始位置判断是否够预计需要查询的长度
        if (len > size && size > 0) {
            result = new StorageInfo[](size);
        } else {
            result = new StorageInfo[](len);
        }
        // 开始遍历赋值
        for (uint256 i = len - 1; j < res.length; ) {
            result[j] = newMapStorageInfo(res[i]);
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
    function newMapStorageInfo(uint256 tsp) public view returns (StorageInfo memory) {
        StorageInfo memory file = getStorage(msg.sender,tsp);
        return StorageInfo({
             name:file.name,
             dataType:file.dataType,
             content: decrypt(bytes(file.content)),
             timestamp:file.timestamp
        });
    }

    // 根据字符条件，匹配过滤数组
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
        // 遍历过滤符合条件的查询
        for (uint256 i = 0; i < klen; i++) {
            uint256 tsp = kl[i];
            bool isMatched = contains(getStorage(msg.sender,tsp).name, subName);
            if (isMatched) {
                buf[len] = tsp;
                len++;
            }
        }
        // 截取有效的数组部分
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

}
