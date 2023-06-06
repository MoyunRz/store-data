// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0 <0.9.0;
import "../node_modules/@openzeppelin/contracts/access/AccessControl.sol";
import "./Storages.sol";

contract DataStorage is Utils, Storages,AccessControl {
    event FileStored(
        string name,
        string dataType,
        string content,
        bytes32 md5,
        address pubAddress,
        uint256 timestamp
    );

    constructor() {
        // 构建默认的管理员权限
        _setupRole(DEFAULT_ADMIN_ROLE, msg.sender);
    }
    // 存储文件内容
    function storeFile(
        string memory name,
        string memory dataType,
        string memory content,
        address pubAddress
    ) public {
        bytes32 md5 = calculateMD5(content);
        uint256 timestamp = block.timestamp; //获取当前区块链时间戳
        StorageInfo memory info = StorageInfo({
            name: name,
            dataType: dataType,
            content: content,
            md5: md5,
            pubAddress: msg.sender,
            timestamp: timestamp
        });
        setStorage(info, msg.sender);
        emit FileStored(name, dataType, content, md5, pubAddress, timestamp);
    }

    // 根据时间 名字查询
    function FindHistory(
        string memory fileName,
        uint256 startTime,
        uint256 endTime,
        uint256 startIndex,
        uint256 size
    ) public view returns (StorageInfo[] memory) {
        return
            findDataHistory(
                fileName,
                startTime,
                endTime,
                startIndex,
                size,
                msg.sender
            );
    }

    function FindStorage(
        string memory fileName,
        uint256 startTime,
        uint256 endTime
    ) public view returns (StorageInfo[] memory) {
        return findDataStorage(fileName, startTime, endTime, msg.sender);
    }

    function FindOwnerList() public view returns (uint256[] memory) {
        return getTimelist(msg.sender);
    }

    function FindOwnerDataByTsp(
        uint256 tsp
    ) public view returns (StorageInfo memory) {
        return findDataByTsp(tsp, msg.sender);
    }
    
    function FindHistoryList(
        address sender
    ) public view onlyRole(DEFAULT_ADMIN_ROLE) returns (uint256[] memory) {
        return getTimelist(sender);
    }
   
    function FindByTsp(
        uint256 tsp,
        address sender
    ) public view onlyRole(DEFAULT_ADMIN_ROLE) returns (StorageInfo memory) {
        return findDataByTsp(tsp, sender);
    }
}
