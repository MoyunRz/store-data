// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0 <0.9.0;

contract ShareAuth {

    mapping(address => mapping(bytes32 => uint256)) private share_limit;

    mapping(bytes32 => uint256) private share_all;

    // 设置共享权限
    function setAuth(address addr,bytes32 md5,uint256 endTime) public {
        if (addr != address(0)) {
            share_limit[addr][md5] = endTime;
        }else{
            share_all[md5] = endTime;
        }
    }

    // 获取md5对应的文件读取权限
    function verifyAuth(address addr,bytes32 md5) public view returns(bool) {
        uint256 limitTime = share_limit[addr][md5];
        uint256 allTime = share_all[md5];
        bool isOpen = limitTime != 0 && (limitTime == 1 || limitTime > block.timestamp);
        isOpen = allTime != 0 && (allTime == 1 || allTime > block.timestamp);
        return  isOpen;
    }
}