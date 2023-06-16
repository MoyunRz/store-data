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
        string name,        // 数据名
        string dataType,    // 数据类型
        string content,     // 加密内容
        bytes32 md5,        // 内容md5
        uint256 timestamp,  // 时间戳
        bytes ownerPub,     // 拥有者的加密公钥
        bytes keyPub        // 另一个加密公钥
    );

    constructor() {
        // 构建默认的管理员权限
        _setupRole(DEFAULT_ADMIN_ROLE, msg.sender);
    }

    // 存储文件内容
    function storeData(
        string memory _name,
        string memory _dataType,
        string memory _content,
        bytes32 _md5,
        bytes memory _ownerPub,
        bytes memory _keyPub
    ) public {
        require(_md5 == keccak256(bytes(_content)), "content is invalid");
        //获取当前区块链时间戳
        uint256 _timestamp = block.timestamp;
        StorageInfo memory info = StorageInfo({
            name: _name,
            dataType: _dataType,
            content: _content,
            md5: _md5,
            timestamp: _timestamp,
            ownerPub: _ownerPub,
            keyPub: _keyPub
        });
        _setStorage(info, msg.sender);
        emit dataStored(_name, _dataType, _content, _md5, _timestamp, _ownerPub, _keyPub);
    }

    // 根据时间 名字查询
    function FindHistory(
        string memory _fileName,
        uint256 _startTime,
        uint256 _endTime,
        uint256 _startIndex,
        uint256 _size
    ) public view returns (StorageInfo[] memory) {
        return _findDataHistory(_fileName,  _startTime, _endTime, _startIndex, _size, msg.sender);
    }

    // 查找
    function FindStorage(
        string memory _fileName,
        uint256 _startTime,
        uint256 _endTime
    ) public view returns (StorageInfo[] memory) {
        return _findDataStorage(_fileName, _startTime, _endTime, msg.sender);
    }

    // 查找拥有的文件列表
    function FindOwnerList() public view returns (uint256[] memory) {
        return _getTimelist(msg.sender);
    }

    // 根据时间戳查询
    function FindOwnerDataByTsp(
        uint256 _tsp
    ) public view returns (StorageInfo memory) {
        return _findDataByTsp(_tsp, msg.sender);
    }

    // 查询用户的文件列表
    function FindHistoryList(
        address _sender
    ) public view onlyRole(DEFAULT_ADMIN_ROLE) returns (uint256[] memory) {
        return _getTimelist(_sender);
    }

    // 根据时间戳查询
    function FindByTsp(
        uint256 _tsp,
        address _sender
    ) public view onlyRole(DEFAULT_ADMIN_ROLE) returns (StorageInfo memory) {
        return _findDataByTsp(_tsp, _sender);
    }

    // 设置共享权限
    function setLimitAuth(
        address[] memory _addr,
        uint256 _tsp,
        uint256 _endTime,
        LimitEnum _enumType
    ) public {
        StorageInfo memory res = _findDataByTsp(_tsp, msg.sender);
        if (_enumType == LimitEnum.ALL) {
            _setOpenAllAuth(res.md5, _tsp, _endTime);
        } else {
            _setLimitAuth(_addr, res.md5, _tsp, _endTime);
        }
    }

    // 取消分享
    function _cencelLimit(
        address[] memory _addr,
        bytes32 _md5,
        LimitEnum _enumType
    ) public {
        if (_enumType == LimitEnum.ALL) {
            _cencelAllShare(_md5);
        } else {
            _cencelShare(_addr, _md5);
        }
    }

    // 查询分享的数据
    function findShareData(
        bytes32 _md5,
        bytes memory _signature
    ) public view returns (StorageInfo memory) {
        require(verify(_md5, _signature), "sender is not signer");
        require(
            _verifyAuth(msg.sender, _md5),
            "You do not have view permission"
        );
        uint256 tsp = _getIndex(_md5);
        address _onwer = _getOnwer(_md5);
        return _findDataByTsp(tsp, _onwer);
    }
}
