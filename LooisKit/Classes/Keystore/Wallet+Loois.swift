//
//  Wallet+Loois.swift
//  LooisKit
//
//  Created by Daven on 2018/7/21.
//  Copyright © 2018年 Loois. All rights reserved.
//

import Foundation
import TrustKeystore
import TrustCore

extension Wallet {
  
  public var firstAccount: Account? {
    return accounts.first
  }
  
  public var firstAccountEthereumAddress: EthereumAddress? {
    return firstAccount?.address as? EthereumAddress
  }
  
  public func privateKey(password: String, derivationPath: DerivationPath = Coin.ethereum.derivationPath(at: 0)) throws -> PrivateKey {
    switch key.type {
    case .encryptedKey:
      var thekey = try key.decrypt(password: password)
      defer {
        // Clear memory after signing
        thekey.resetBytes(in: 0..<thekey.count)
      }
      return PrivateKey(data: thekey)!
    case .hierarchicalDeterministicWallet:
      guard var mnemonic = String(data: try key.decrypt(password: password), encoding: .ascii) else {
        throw DecryptError.invalidPassword
      }
      defer {
        // Clear memory after signing
        mnemonic.clear()
      }
      let wallet = HDWallet(mnemonic: mnemonic, passphrase: key.passphrase)
      return wallet.getKey(at: derivationPath)
    }
  }
  
}
