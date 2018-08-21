# Loois iOS SDK

此仓库是 [Loois团队](https://github.com/LOOIS-IO/) 提供的方便开发者接入钱包的SDK. 

Loois iOS SDK提供了常规的以太坊钱包功能和基于[路印协议](https://loopring.org/)Relay的交易等功能及便捷API.

## 功能

### 钱包基础功能
- [x] 生成钱包
  - [x] [创建钱包](#创建钱包)
  - [x] [BIP39助记符(Mnemonic Phrase)导入钱包](#通过助记词导入)
  - [x] [私钥(Private Key)导入钱包](#通过私钥导入)
  - [x] [Keystore文件导入钱包](#通过Keystore导入)
- [x] 导出钱包(#导出钱包)
  - [x] [导出私钥](#导出私钥)
  - [x] [导出助记符](#导出助记符)
  - [x] [导出Keystore文件](#导出Keystore文件)
- [x] [修改Keystore密码](#修改Keystore密码)
- [x] [删除钱包](#删除钱包)
- [x] [交易签名](#交易签名)

### Etherum API
- [ ] getTransactionCount
- [ ] sendRawTransaction
- [ ] call
- [ ] getPrice
- [ ] estimateGas
- [ ] getTransactionByHash

### Loopring Relay API
- [ ] getBalance
- [ ] getPriceQuote
- [ ] getMarkets
- [ ] getSupportedTokens
- [ ] getTransactions
- [ ] getExchangetMarket
- [ ] notifyTransactionSubmitted
- [ ] searchLocalTokens
- [ ] registerToken
- [ ] unlockWallet
- [ ] getNonce

### Loopring Relay SoketIO
- [ ] getBalance
- [ ] getPriceQuote
- [ ] loopringTickers
- [ ] portfolio
- [ ] tickers
- [ ] marketcap
- [ ] depth
- [ ] trends
- [ ] pendingTx


## 集成

```
pod 'LooisKit' ~> '0.0.5'
```

## 使用示例

### 生成钱包

#### 创建钱包
  
  ```swift
    let keystore = EtherKeystore(keysSubfolder: "/keystore")
    let buildType: BuildType = .create(newPassword: [YOUR PASSWORD])
    keystore.buildWallet(type: buildType, completion: { (result) in
      print("wallet address: ", result.value, "or error: ", result.error)
    }
  ```

#### 通过助记词导入
  
  ```swift
    let keystore = EtherKeystore(keysSubfolder: "/keystore")
    let buildType: BuildType = .mnemonic(words: [YOUR MNEMONICS WORDS ARRAY], newPassword: [YOUR PASSWORD])
    keystore.buildWallet(type: buildType, completion: { (result) in
      print("wallet address: ", result.value, "or error: ", result.error)
    }
  ```
    
#### 通过私钥导入
  
  ```swift
    let keystore = EtherKeystore(keysSubfolder: "/keystore")
    let buildType: BuildType = .privateKey(privateKey: [YOUR PRIVATE KEY STRING], newPassword: [YOUR PASSWORD])
    keystore.buildWallet(type: buildType, completion: { (result) in
      print("wallet address: ", result.value, "or error: ", result.error)
    }
  ```
    
#### 通过Keystore导入
  
  ```swift
    let keystore = EtherKeystore(keysSubfolder: "/keystore")
    let buildType: BuildType = .keystore(string: [YOUR KEYSTORE STRING], password: [YOUR PASSWORD], newPassword: [YOUR PASSWORD])
    keystore.buildWallet(type: buildType, completion: { (result) in
      print("wallet address: ", result.value, "or error: ", result.error)
    }
  ```

### 导出钱包

#### 导出私钥
  
  ```swift
    let keystore = EtherKeystore(keysSubfolder: "/keystore")
    guard let wallet = keystore.wallet(for: [THE WALLET ADDRESS STRING]) else { return }
    let exportType: ExportType = .privateKey(wallet: wallet, password: [YOUR PASSWORD])
    keystore.exportWallet(type: exportType, completion: { (result) in
      print("exported keystore string: ", result.value, "or error: ", result.error)
    }
  ```
  
#### 导出助记符
注：Loois SDK 不以任何方式存储用户的助记符
  
#### 导出Keystore文件
  
  ```swift
    let keystore = EtherKeystore(keysSubfolder: "/keystore")
    guard let wallet = keystore.wallet(for: [THE WALLET ADDRESS STRING]) else { return }
    let exportType: ExportType = .keystore(wallet: wallet, password: [YOUR PASSWORD], newPassword: [YOUR PASSWORD])
    keystore.exportWallet(type: exportType, completion: { (result) in
      print("exported keystore string: ", result.value, "or error: ", result.error)
    }
  ```

### 修改Keystore密码

```swift
  let keystore = EtherKeystore(keysSubfolder: "/keystore")
  guard let wallet = keystore.wallet(for: [THE WALLET ADDRESS STRING]) else { return }
  keystore.update(wallet: wallet, password: [YOUR PASSWORD], newPassword: [YOUR PASSWORD], completion: { (result) in
    print("update result is: ", result.value, "or error: ", result.error)
  }
```

### 删除钱包

```swift
  let keystore = EtherKeystore(keysSubfolder: "/keystore")
  guard let wallet = keystore.wallet(for: [THE WALLET ADDRESS STRING]) else { return }
  keystore.delete(wallet: wallet, password: "12345678", completion: { (result) in
    print("delete result is: ", result.value, "or error: ", result.error)
  }
```

### 交易签名

```swift
  let keystore = EtherKeystore(keysSubfolder: "/keystore")
  guard let wallet = keystore.wallet(for: [THE WALLET ADDRESS STRING]) else { return }
  
  let contractAddress = EthereumAddress(string: [ADDRESS]) // WETH
  let encoder = FunctionRawEncoder.transfer(to: EthereumAddress(string: [ADDRESS])!,
                                        amount: 1_000_000_000_000_000)
  let st = RawTransaction(nonce: 539,
                       gasPrice: 5140490000,
                       gasLimit: 60000,
                          value: 0,
                             to: contractAddress,
                          data: encoder.encodedData,
                   functionRaw: encoder.function.signature)
  let signed = HomesteadSigner().sign(transaction: st, wallet: wallet, password: [YOUR PASSWORD])
  print("signed string: ", signed.value?.hexString, "or error: ", signed.error)
```



