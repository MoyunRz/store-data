// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0 <0.9.0;
import "../node_modules/@openzeppelin/contracts/utils/cryptography/ECDSA.sol";

contract ShareAuth {

    // 文件所有权
    mapping(bytes32 => address) private shareOwner;
    mapping(bytes32 => uint256) private shareTsp;
    // 分享限制
    mapping(bytes32 => mapping(address => uint256)) private shareLimit;
    // 分享没有限制
    mapping(bytes32 => uint256) private shareAll;
    // 直接关闭分享
    mapping(bytes32 => bool) private isOpen;


    // 设置共享权限
    function _setLimitAuth(address[] memory _addr,bytes32 _md5,uint256 _tsp,uint256 _endTime) internal {
        require(_endTime > 0 ,"endTime need than 0");
        require(_addr.length > 0 ,"address is not null");
        require(_md5.length > 0 ,"md5 is not null");
        shareOwner[_md5] = msg.sender;
        shareTsp[_md5]= _tsp;
        for(uint256 i = 0; i < _addr.length;i++){
            shareLimit[_md5][_addr[i]] = _endTime;
        }
        isOpen[_md5] = true;
    }
    
    // 设置开启权限
    function _setOpenAllAuth(bytes32 _md5,uint256 _tsp,uint256 _endTime) internal {
        require(_endTime > 0 ,"endTime need than 0");
        require(_md5.length > 0 ,"md5 is not null");
        shareOwner[_md5] = msg.sender;
        shareTsp[_md5]= _tsp;
        shareAll[_md5] = _endTime;
        isOpen[_md5] = true;
    }

    // 获取md5对应的文件读取权限
    function _cencelShare(address[] memory _addr,bytes32 _md5) internal {
        require(_md5.length > 0 ,"md5 is not null");
        shareAll[_md5] = block.timestamp;
        for(uint256 i = 0; i < _addr.length;i++){
            shareLimit[_md5][_addr[i]] = block.timestamp - 1;
        }
    }

    // 获取md5对应的文件读取权限
    function _cencelAllShare(bytes32 _md5) internal {
        require(_md5.length > 0 ,"md5 is not null");
        shareAll[_md5] = block.timestamp;
        isOpen[_md5] = false;
    }

    // 获取md5对应的文件读取权限
    function _verifyAuth(address _addr,bytes32 _md5) internal view returns(bool) {
        if (shareOwner[_md5] == msg.sender) return true;
        if(!isOpen[_md5]) return false;
        uint256 limitTime = shareLimit[_md5][_addr];
        uint256 allTime = shareAll[_md5];
        return  (limitTime != 0 && (limitTime == 1 || limitTime > block.timestamp)|| allTime != 0 && (allTime == 1 || allTime > block.timestamp));
    }

    // 利用ECDSA验证签名并mint
    function verify(bytes32 _msgHash, bytes memory _signature) public view returns(bool) {
        // 将_account和_tokenId打包消息
        // 计算以太坊签名消息
        bytes32 _ethSignedMessageHash = ECDSA.toEthSignedMessageHash(_msgHash); 
        address recovered = ECDSA.recover(_ethSignedMessageHash, _signature);
        return recovered == msg.sender;
    }

    function _getIndex(bytes32 md5) internal view returns(uint256){
        return shareTsp[md5];
    }
    function _getOnwer(bytes32 md5) internal view returns(address){
        return shareOwner[md5];
    }
}