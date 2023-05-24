/*
 * uncomment accounts to access the test accounts made available by the
 * Ethereum client
 * See docs: https://www.trufflesuite.com/docs/truffle/testing/writing-tests-in-javascript
 */
const { expect } = require('chai');

const { BN, constants, expectEvent, expectRevert, time } = require('@openzeppelin/test-helpers'); //导入OpenZeppelin的测试助手
const FileStorage = artifacts.require("FileStorage"); //导入我们的智能合约
const truffleAssert = require('truffle-assertions'); //导入Truffle Assertions

contract("FileStorage", (accounts) => {
  let fileStorage;

  beforeEach(async () => {
    fileStorage = await FileStorage.new();
  });

  describe("storeFile", () => {
    it("should store a new file with correct values", async () => {
      const fileType = "text/plain";
      const fileContent = "Hello world!";
      const tx = await fileStorage.storeFile(fileType, fileContent, { from: accounts[0], gas: 6712388 });
      
      truffleAssert.eventEmitted(tx, 'FileStored', (ev) => {
        return ev.fileType === fileType && ev.fileContent === fileContent;
      }, 'FileStored event should be emitted with correct parameters');

      const storedFile = await fileStorage.getFiles(0, constants.MAX_UINT256);
      expect(storedFile[0].fileType).to.equal(fileType);
      expect(storedFile[0].fileContent).to.equal(fileContent);
    });
  });

  describe("getFiles", () => {
    it("should return all files within the given time range", async () => {

      const fileType1 = "text/plain";
      const fileContent1 = "Hello world!";
      await fileStorage.storeFile(fileType1, fileContent1, { from: accounts[0], gas: 6712388 });
      
      //增加时间等待
      await time.increase(100);
    
      const fileType2 = "image/png";
      const fileContent2 = "iVBORw0KGgoAAAANSUhEUgAAAAEAAAABCAYAAAAfFcSJAAAADUlEQVQYV2P8z/D/PwAHggJ/Pj9LgAAAABJRU5ErkJggg==";
      await fileStorage.storeFile(fileType2, fileContent2, { from: accounts[0], gas: 6712388 });

      const storedFiles = await fileStorage.getFiles(0, constants.MAX_UINT256);
      console.log(storedFiles)
      expect(storedFiles[0].fileType).to.equal(fileType1);
      expect(storedFiles[0].fileContent).to.equal(fileContent1);
      expect(storedFiles[1].fileType).to.equal(fileType2);
      expect(storedFiles[1].fileContent).to.equal(fileContent2);
    });
  });
});
