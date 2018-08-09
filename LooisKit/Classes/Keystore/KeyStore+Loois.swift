//
//  KeyStore+Loois.swift
//  LooisKit
//
//  Created by Daven on 2018/8/8.
//  Copyright © 2018年 Loois. All rights reserved.
//

import Foundation
import TrustCore
import TrustKeystore

extension KeyStore {
  
  func ifExists(account: Account) {
    
  }
  
  func `import`(json: Data, password: String, newPassword: String) throws -> Wallet {
    let key = try JSONDecoder().decode(TrustKeystore.KeystoreKey.self, from: json)
    
    var privateKeyData = try key.decrypt(password: password)
    defer {
      privateKeyData.clear()
    }
    guard let privateKey = PrivateKey(data: privateKeyData) else {
      throw Error.invalidKey
    }
    return try self.import(privateKey: privateKey, password: newPassword)
  }
  
//  func `import`(privateKey: PrivateKey, password: String) throws -> Wallet {
//    let newKey = try TrustKeystore.KeystoreKey(password: password, key: privateKey)
//    let url = makeAccountURL()
//    let wallet = Wallet(keyURL: url, key: newKey)
//    let _ = try wallet.getAccount(password: password, coin: .ethereum)
//    wallets.append(wallet)
//
//    try save(wallet: wallet, in: keyDirectory)
//
//    return wallet
//  }
  
  func _export(wallet: Wallet, password: String, newPassword: String) throws -> Data {
    var privateKeyData = try wallet.key.decrypt(password: password)
    defer {
      privateKeyData.resetBytes(in: 0 ..< privateKeyData.count)
    }
    let newKey: KeystoreKey
    switch wallet.key.type {
    case .encryptedKey:
      guard let privateKey = PrivateKey(data: privateKeyData) else {
        throw Error.invalidKey
      }
      var key = try TrustKeystore.KeystoreKey(password: newPassword, key: privateKey)
      key.address = privateKey.publicKey(for: .ethereum).address.data.hexString
      newKey = KeystoreKey(key: key)

    case .hierarchicalDeterministicWallet:
      guard var string = String(data: privateKeyData, encoding: .ascii) else {
        throw EncryptError.invalidMnemonic
      }
      if string.hasSuffix("\0") {
        string.removeLast(1)
      }
      let privateKey = try wallet.privateKey(password: password)
      
      var key = try TrustKeystore.KeystoreKey(password: newPassword, mnemonic: string, passphrase: wallet.key.passphrase)
      key.address = privateKey.publicKey(for: .ethereum).address.data.hexString
      newKey = KeystoreKey(key: key)
    }
    return try JSONEncoder().encode(newKey)
  }
  
}
