// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0 <0.9.0;

contract Storages {
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

    function setStorage(StorageInfo memory data) internal {
        storage_datas[msg.sender][data.timestamp] = data;
        timelist[msg.sender].push(data.timestamp);
    }

    function getTimelist(address key) internal view returns (uint256[] memory) {
        return timelist[key];
    }

    function getStorage(
        address key,
        uint256 tsp
    ) internal view returns (StorageInfo memory) {
        return storage_datas[key][tsp];
    }
}
