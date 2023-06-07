// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0 <0.9.0;
import "../node_modules/@openzeppelin/contracts/access/AccessControl.sol";
import "./Storages.sol";
import "./ShareAuth.sol";

contract DataStorage is Storages, ShareAuth, AccessControl {
    enum LimitEnum {
        ALL,
        LIMIT
    }

    event dataStored(
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
    function storeData(
        string memory name,
        string memory dataType,
        string memory content,
        address pubAddress
    ) public {
        bytes32 md5 = keccak256(bytes(content));
        uint256 timestamp = block.timestamp; //获取当前区块链时间戳
        StorageInfo memory info = StorageInfo({
            name: name,
            dataType: dataType,
            content: content,
            md5: md5,
            pubAddress: pubAddress,
            timestamp: timestamp
        });
        _setStorage(info, msg.sender);
        emit dataStored(name, dataType, content, md5, pubAddress, timestamp);
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
            _findDataHistory(
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
        return _findDataStorage(fileName, startTime, endTime, msg.sender);
    }

    function FindOwnerList() public view returns (uint256[] memory) {
        return _getTimelist(msg.sender);
    }

    function FindOwnerDataByTsp(
        uint256 tsp
    ) public view returns (StorageInfo memory) {
        return _findDataByTsp(tsp, msg.sender);
    }

    function FindHistoryList(
        address sender
    ) public view onlyRole(DEFAULT_ADMIN_ROLE) returns (uint256[] memory) {
        return _getTimelist(sender);
    }

    function FindByTsp(
        uint256 tsp,
        address sender
    ) public view onlyRole(DEFAULT_ADMIN_ROLE) returns (StorageInfo memory) {
        return _findDataByTsp(tsp, sender);
    }

    function setLimitAuth(
        address[] memory addr,
        uint256 tsp,
        uint256 endTime,
        LimitEnum enumType
    ) public {
        StorageInfo memory res = _findDataByTsp(tsp, msg.sender);
        if (enumType == LimitEnum.ALL) {
            _setOpenAllAuth(res.md5, tsp, endTime);
        } else {
            _setLimitAuth(addr, res.md5, tsp, endTime);
        }
    }

    function setLimitAuth(
        address[] memory addr,
        bytes32 md5,
        LimitEnum enumType
    ) public {
        if (enumType == LimitEnum.ALL) {
            _cencelAllShare(md5);
        } else {
            _cencelShare(addr, md5);
        }
    }

    function findShareData(
        bytes32 md5,
        bytes memory _signature
    ) public view returns (StorageInfo memory) {
        require(verify(md5, _signature), "sender is not signer");
        require(_verifyAuth(msg.sender, md5), "You do not have view permission");
        uint256 tsp = _getIndex(md5);
        address _onwer = _getOnwer(md5);
        return _findDataByTsp(tsp, _onwer);
    }
}
