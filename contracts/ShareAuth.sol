// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0 <0.9.0;
import "../node_modules/@openzeppelin/contracts/utils/cryptography/ECDSA.sol";

contract ShareAuth {
    // 分享限制
    mapping(bytes32 => mapping(address => uint256)) private share_limit;
    // 分享没有限制
    mapping(bytes32 => uint256) private share_all;
    // 直接关闭分享
    mapping(bytes32 => bool) private is_open;

    // 设置共享权限
    function setLimitAuth(address[] memory addr,bytes32 md5,uint256 endTime) internal {

        require(endTime > 0 ,"endTime need than 0");
        require(addr.length > 0 ,"address is not null");
        require(md5.length > 0 ,"md5 is not null");

        if (share_limit[md5][msg.sender] ==0 ) {
            share_limit[md5][msg.sender] == 1;
        }
        for(uint256 i = 0; i < addr.length;i++){
            share_limit[md5][addr[i]] == endTime;
        }
        is_open[md5] = true;
    }

    function setOpenAuth(bytes32 md5,uint256 endTime) internal {
        require(endTime > 0 ,"endTime need than 0");
        require(md5.length > 0 ,"md5 is not null");
        if (share_limit[md5][msg.sender] ==0 ) {
            share_limit[md5][msg.sender] == 1;
        }
        share_all[md5] == endTime;
        is_open[md5] = true;
    }

    // 获取md5对应的文件读取权限
    function cencelShare(address[] memory addr,bytes32 md5) internal {
        require(md5.length > 0 ,"md5 is not null");
        share_all[md5] == block.timestamp;
        if(addr.length == 0) {
            is_open[md5] = false;
            return;
        }
        for(uint256 i = 0; i < addr.length;i++){
            share_limit[md5][addr[i]] = block.timestamp - 1;
        }
    }

    // 获取md5对应的文件读取权限
    function verifyAuth(address addr,bytes32 md5) internal view returns(bool) {
        if(!is_open[md5]) return false;
        uint256 limitTime = share_limit[md5][addr];
        uint256 allTime = share_all[md5];
        bool isOpen = limitTime != 0 && (limitTime == 1 || limitTime > block.timestamp);
        isOpen = allTime != 0 && (allTime == 1 || allTime > block.timestamp);
        return  isOpen;
    }

    // 利用ECDSA验证签名并mint
    function verify(string memory _msg, bytes memory _signature)
    public view returns(bool)
    {
        bytes32 _msgHash = getMessageHash(_msg); // 将_account和_tokenId打包消息
        bytes32 _ethSignedMessageHash = ECDSA.toEthSignedMessageHash(_msgHash); // 计算以太坊签名消息
        address recovered = ECDSA.recover(_ethSignedMessageHash, _signature);
        return recovered == msg.sender;
    }

    /*
     * 将mint地址（address类型）和tokenId（uint256类型）拼成消息msgHash
       * _msg: 消息
     * 对应的消息: keccak256 后的hash
     */
    function getMessageHash(string memory _msg) public pure returns(bytes32){
        return keccak256(bytes(_msg));
    }
}