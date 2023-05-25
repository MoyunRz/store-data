# store-data

这是一个存储文件内容的合约，支持时间范围查询、名字模糊查询

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

```shell
npm i
```

```shell
truffle test --network development
```
