// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0 <0.9.0;
import "./Utils.sol";
contract Storages is Utils {
    // 构建文件内容存储结构体
    struct StorageInfo {
        string name; // 聊天信息备注 便于查询
        string dataType; // 数据类型
        string content; // 聊天内容
        bytes32 md5;    // 内容md5
        address pubAddress; // 公钥
        uint256 timestamp; // 时间戳
    }

    // uint256 记录键值，减少大面积查询，避免耽误查询时间
    mapping(address => uint256[]) timelist;
    // 用于存储数据的映射
    // uint256 是时间戳，如：1684832014
    mapping(address => mapping(uint256 => StorageInfo)) private storage_datas;

    function _setStorage(StorageInfo memory data,address sender) internal {
        storage_datas[sender][data.timestamp] = data;
        timelist[sender].push(data.timestamp);
    }

    function _getTimelist(address key) internal view returns (uint256[] memory) {
        return timelist[key];
    }

    function _getStorage(
        address key,
        uint256 tsp
    ) internal view returns (StorageInfo memory) {
        return storage_datas[key][tsp];
    }

    // 查询数据信息
    function _findDataStorage(
        string memory fileName,
        uint256 startTime,
        uint256 endTime,
        address sender
    ) internal view returns (StorageInfo[] memory) {
        uint256[] memory kl = _getTimelist(sender);
        if (startTime < endTime && endTime > 0) {
            kl = _queryIndex(startTime, endTime,sender);
            if (kl.length == 0) {
                return new StorageInfo[](0);
            }
        }
        // 获取匹配的数组
        uint256[] memory res = _filterListBySubStr(fileName, kl,sender);
        if (res.length == 0) {
            return new StorageInfo[](0);
        }
        uint256 j = 0;
        StorageInfo[] memory result = new StorageInfo[](res.length);
        for (uint256 i = res.length - 1; j < res.length; ) {
            result[j] = _findDataByTsp(res[i],sender);
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
    function _findDataHistory(
        string memory fileName,
        uint256 startTime,
        uint256 endTime,
        uint256 startIndex,
        uint256 size,
        address sender
    ) internal view returns (StorageInfo[] memory) {
        // 获取该地址有的存储
        uint256[] memory kl = _getTimelist(sender);
        // 根据时间遍历查询key值
        if (startTime < endTime && endTime > 0) {
            kl = _queryIndex(startTime, endTime,sender);
            if (kl.length == 0) {
                return new StorageInfo[](0);
            }
        }
        // 获取匹配的数组
        uint256[] memory res = _filterListBySubStr(fileName, kl,sender);
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
            result[j] = _findDataByTsp(res[i],sender);
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
    function _findDataByTsp(
        uint256 tsp,
        address sender
    ) internal view returns (StorageInfo memory) {
        StorageInfo memory data = _getStorage(sender, tsp);
        return
            StorageInfo({
                name: data.name,
                dataType: data.dataType,
                content: data.content,
                md5: data.md5,
                pubAddress: data.pubAddress,
                timestamp: data.timestamp
            });
    }

    // 根据字符条件，匹配过滤数组
    function _filterListBySubStr(
        string memory subName,
        uint256[] memory kl,
        address sender
    ) private view returns (uint256[] memory) {
        uint256 klen = kl.length;
        if (bytes(subName).length == 0 || klen == 0) {
            return kl;
        }
        uint256 len = 0;
        uint256[] memory buf = new uint256[](klen);
        // 遍历过滤符合条件的查询
        for (uint256 i = 0; i < klen; i++) {
            uint256 tsp = kl[i];
            bool isMatched = contains(
                _getStorage(sender, tsp).name,
                subName
            );
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

    // 根据时间进行查询
    function _queryIndex(
        uint256 startTime,
        uint256 endTime,
        address sender
    ) internal view returns (uint256[] memory) {
        uint256 length = 0;
        uint256 end = 0;
        uint256[] memory kl = _getTimelist(sender);
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
