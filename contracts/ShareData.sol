// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0 <0.9.0;

contract ShareData {

    mapping(address => mapping(string => uint256)) private share_limit;

    mapping(string => uint256) private share_all;

    function shareSetting(address addr,string memory md5,uint256 endTime) public {
        if (addr != address(0)) {
            share_limit[addr][md5] = endTime;
        }else{
            share_all[md5] = endTime;
        }
    }
     
    function getAuth(address addr,string memory md5) public view returns(bool) {
        uint256 limitTime = share_limit[addr][md5];
        uint256 allTime = share_all[md5];
        bool isOpen = limitTime != 0 && (limitTime == 1 || limitTime > block.timestamp);
        isOpen = allTime != 0 && (allTime == 1 || allTime > block.timestamp);
        return  isOpen;
    }
}