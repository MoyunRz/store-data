// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0 <0.9.0;
import "../node_modules/@openzeppelin/contracts/utils/cryptography/ECDSA.sol";

contract ShareAuth {

    // 文件所有权
    mapping(bytes32 => address) private share_onwer;
    mapping(bytes32 => uint256) private share_tsp;
    // 分享限制
    mapping(bytes32 => mapping(address => uint256)) private share_limit;
    // 分享没有限制
    mapping(bytes32 => uint256) private share_all;
    // 直接关闭分享
    mapping(bytes32 => bool) private is_open;


    // 设置共享权限
    function _setLimitAuth(address[] memory addr,bytes32 md5,uint256 tsp,uint256 endTime) internal {
        require(endTime > 0 ,"endTime need than 0");
        require(addr.length > 0 ,"address is not null");
        require(md5.length > 0 ,"md5 is not null");
        share_onwer[md5] = msg.sender;
        share_tsp[md5]= tsp;
        for(uint256 i = 0; i < addr.length;i++){
            share_limit[md5][addr[i]] == endTime;
        }
        is_open[md5] = true;
    }
    
    // 设置开启权限
    function _setOpenAllAuth(bytes32 md5,uint256 tsp,uint256 endTime) internal {
        require(endTime > 0 ,"endTime need than 0");
        require(md5.length > 0 ,"md5 is not null");
        share_onwer[md5] = msg.sender;
        share_tsp[md5]= tsp;
        share_all[md5] == endTime;
        is_open[md5] = true;
    }

    // 获取md5对应的文件读取权限
    function _cencelShare(address[] memory addr,bytes32 md5) internal {
        require(md5.length > 0 ,"md5 is not null");
        share_all[md5] == block.timestamp;
        for(uint256 i = 0; i < addr.length;i++){
            share_limit[md5][addr[i]] = block.timestamp - 1;
        }
    }

    // 获取md5对应的文件读取权限
    function _cencelAllShare(bytes32 md5) internal {
        require(md5.length > 0 ,"md5 is not null");
        share_all[md5] == block.timestamp;
        is_open[md5] = false;
    }

    // 获取md5对应的文件读取权限
    function _verifyAuth(address addr,bytes32 md5) internal view returns(bool) {
        if (share_onwer[md5] == msg.sender) return true;
        if(!is_open[md5]) return false;
        uint256 limitTime = share_limit[md5][addr];
        uint256 allTime = share_all[md5];
        bool isOpen = limitTime != 0 && (limitTime == 1 || limitTime > block.timestamp);
        isOpen = allTime != 0 && (allTime == 1 || allTime > block.timestamp);
        return  isOpen;
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
        return share_tsp[md5];
    }
    function _getOnwer(bytes32 md5) internal view returns(address){
        return share_onwer[md5];
    }
}