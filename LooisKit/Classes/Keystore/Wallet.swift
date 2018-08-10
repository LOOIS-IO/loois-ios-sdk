//
//  Wallet.swift
//  LooisKit
//
//  Created by Daven on 2018/8/10.
//  Copyright © 2018年 Loois. All rights reserved.
//

import Foundation
import TrustCore

/// 本SDK暂只考虑Etherum钱包且不考虑衍生地址，每个钱包只保留首个path地址
/// Encrypted key wallet.
public final class Wallet: Hashable {
  /// Unique wallet identifier.
  public let identifier: String
  
  /// URL for the key file on disk.
  public var keyURL: URL
  
  /// Encrypted wallet key
  public var key: KeystoreKey
  
  /// Account public address
  public var address: String?
  
  /// Creates a `Wallet` from an encrypted key.
  public init(keyURL: URL, key: KeystoreKey) {
    identifier = keyURL.lastPathComponent
    address = key.address
    self.keyURL = keyURL
    self.key = key
  }
  
  /// Signs a hash with the given password.
  ///
  /// - Parameters:
  ///   - hash: hash to sign
  ///   - password: key password
  /// - Returns: signature
  /// - Throws: `DecryptError` or `Secp256k1Error`
  public func sign(hash: Data, password: String) throws -> Data {
    let key = try privateKey(password: password)
    return Crypto.sign(hash: hash, privateKey: key.data)
  }
  
  /// Signs multiple hashes with the given password.
  ///
  /// - Parameters:
  ///   - hashes: array of hashes to sign
  ///   - password: key password
  /// - Returns: [signature]
  /// - Throws: `DecryptError` or `Secp256k1Error`
  public func signHashes(_ hashes: [Data], password: String) throws -> [Data] {
    let key = try privateKey(password: password)
    return hashes.map({ Crypto.sign(hash: $0, privateKey: key.data) })
  }
  
  public func privateKey(password: String) throws -> PrivateKey {
    var thekey = try key.decrypt(password: password)
    defer {
      // Clear memory after signing
      thekey.resetBytes(in: 0..<thekey.count)
    }
    return PrivateKey(data: thekey)!
  }
  
  public var hashValue: Int {
    return identifier.hashValue
  }
  
  public static func == (lhs: Wallet, rhs: Wallet) -> Bool {
    return lhs.identifier == rhs.identifier
  }
}

/// Support account types.
public enum WalletType {
  case encryptedKey
  case hierarchicalDeterministicWallet
}

public enum WalletError: LocalizedError {
  case invalidKeyType
}
