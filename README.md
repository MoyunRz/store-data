# store-data

这是一个存储文件内容的合约，支持时间范围查询、名字模糊查询

## 目录介绍

```shell
 |---contracts
      |--- DataStorage.sol 查询、存储内容合约 
      |--- ShareAuth.sol 内容、文件共享合约
      |--- Storages.sol 查询、存储内容具体实现合约 
      |--- Utils.sol 工具合约 
```

## 设计

[流程图](./doc/合约存取共享.md)

## 项目依赖

- ganche 本地以太坊环境调试的cli
- node 项目js测试
- truffle 项目框架
- solidity 0.8.19 合约版本

## 配置

在truffle-config.js中配置运行的以太坊网络

```js
networks: {
    development: {
      host: "127.0.0.1",
      port: 7545,
      network_id: "*",
      networkCheckTimeout: 10000
    },
},
```

## 运行测试

测试文件在 test/*.js 中，运行测试文件如下：

```shell
npm i
```

```shell
truffle test --network development
```
