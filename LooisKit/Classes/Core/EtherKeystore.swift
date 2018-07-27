//
//  EtherKeystore.swift
//  LooisKit
//
//  Created by Daven on 2018/7/19.
//  Copyright © 2018年 Loois. All rights reserved.
//

import Foundation
import TrustKeystore
import TrustCore
import Result
import BigInt

class EtherKeystore: Keystore {
    
  private let datadir = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0]
  
  internal let keysDirectory: URL
  internal let keyStore: KeyStore
  
  public init(keysSubfolder: String = "/keystore") {
    self.keysDirectory = URL(fileURLWithPath: datadir + keysSubfolder)
    self.keyStore = try! KeyStore(keyDirectory: keysDirectory)
  }
  
  public func buildWallet(type: BuildType, completion: @escaping (Result<Wallet, KeystoreError>) -> Void) {
    switch type {
    case let .create(newPassword):
      DispatchQueue.executeGlobal(execute: self.createWallet(newPassword: newPassword), main: completion)
    case let .keystore(string, password, newPassword):
      DispatchQueue.executeGlobal(execute: self.import(ksvalue: string, password: password, newPassword: newPassword), main: completion)
    case let .mnemonic(words, newPassword):
      DispatchQueue.executeGlobal(execute: self.import(mnemonic: words, newPassword: newPassword), main: completion)
    case let .privateKey(privateKey, newPassword):
      DispatchQueue.executeGlobal(execute: self.import(privateKey: privateKey, newPassword: newPassword), main: completion)
    }
  }
  
  public func exportWallet(type: ExportType, completion: @escaping (Result<String, KeystoreError>) -> Void) {
    switch type {
    case let .keystore(wallet, password, newPassword):
      DispatchQueue.executeGlobal(execute: self.exportKeystore(wallet: wallet, password: password, newPassword: newPassword), main: completion)
    case let .mnemonic(wallet, password):
      DispatchQueue.executeGlobal(execute: self.exportMnemonic(wallet: wallet, password: password), main: completion)
    case let .privateKey(wallet, password):
      DispatchQueue.executeGlobal(execute: self.exportPrivateKey(wallet: wallet, password: password), main: completion)
    }
  }
  
}

extension EtherKeystore {
  
  fileprivate func exportMnemonic(wallet: Wallet, password: String) -> Result<String, KeystoreError> {
    do {
      let mnemonic = try keyStore.exportMnemonic(wallet: wallet, password: password)
      return .success(mnemonic)
    } catch {
      return .failure(.failedToDecryptKey)
    }
  }
  
  fileprivate func exportPrivateKey(wallet: Wallet, password: String) -> Result<String, KeystoreError> {
    do {
      let privateKey = try wallet.privateKey(password: password).data.hexString
      return .success(privateKey)
    } catch {
      return .failure(.failedToDecryptKey)
    }
  }
  
  fileprivate func exportKeystore(wallet: Wallet, password: String, newPassword: String) -> Result<String, KeystoreError> {
    do {
      let data = try keyStore.export(wallet: wallet, password: password, newPassword: newPassword)
      let string = String(data: data, encoding: .utf8) ?? ""
      return .success(string)
    } catch {
      return .failure(.failedToDecryptKey)
    }
  }
  
  fileprivate func createWallet(newPassword: String) -> Result<Wallet, KeystoreError> {
    do {
      let wallet = try keyStore.createWallet(
        password: newPassword,
        derivationPaths: [Coin.ethereum.derivationPath(at: 0)]
      )
      return .success(wallet)
    } catch {
      return .failure(.failedToCreateWallet)
    }
  }
  
  fileprivate func `import`(ksvalue: String, password: String, newPassword: String) -> Result<Wallet, KeystoreError> {
    guard let data = ksvalue.data(using: .utf8) else {
      return .failure(.failedToParseJSON)
    }
    do {
      let wallet = try keyStore.import(json: data, password: password, newPassword: newPassword)
      return .success(wallet)
    } catch {
      if case KeyStore.Error.accountAlreadyExists = error {
        return .failure(.duplicateAccount)
      } else {
        return .failure(.failedToImport(error))
      }
    }
  }
  
  fileprivate func `import`(mnemonic words: [String], newPassword: String) -> Result<Wallet, KeystoreError> {
    let string = words.map { String($0) }.joined(separator: " ")
    if !Crypto.isValid(mnemonic: string) {
      return .failure(KeystoreError.invalidMnemonicPhrase)
    }
    do {
      let wallet = try keyStore.import(mnemonic: string, passphrase: "", encryptPassword: newPassword, derivationPath: Coin.ethereum.derivationPath(at: 0))
      return .success(wallet)
    } catch {
      return .failure(KeystoreError.duplicateAccount)
    }
  }
  
  fileprivate func `import`(privateKey: String, newPassword: String) -> Result<Wallet, KeystoreError> {
    guard let data = Data(hexString: privateKey),
      let privateKeyData = PrivateKey(data: data) else {
        return .failure(KeystoreError.invalidPrivateKey)
    }
    do {
      let wallet = try keyStore.import(privateKey: privateKeyData, password: newPassword)
      return .success(wallet)
    } catch {
      return .failure(KeystoreError.failedToImportPrivateKey)
    }
  }
  
}
