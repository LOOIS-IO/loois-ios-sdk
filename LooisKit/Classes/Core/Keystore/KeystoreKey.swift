//
//  KeystoreKey.swift
//  LooisKit
//
//  Created by Daven on 2018/8/8.
//  Copyright © 2018年 Loois. All rights reserved.
//

import Foundation
import CryptoSwift
import TrustCore

public struct KeystoreKey {
  
  public var id: String?
  
  public var address: String?
  
  public var crypto: KeystoreKeyHeader
  
  public var version = 3
  
  /// Initializes a `Key` from a JSON wallet.
  public init(contentsOf url: URL) throws {
    let data = try Data(contentsOf: url)
    self = try JSONDecoder().decode(KeystoreKey.self, from: data)
  }
  
  /// Initializes a `Key` by encrypting a private key with a password.
  public init(password: String, key: PrivateKey) throws {
    id = UUID().uuidString.lowercased()
    crypto = try KeystoreKeyHeader(password: password, data: key.data)
    address = key.publicKey(for: .ethereum).address.data.hexString
  }
  
  /// Decrypts the key and returns the private key.
  public func decrypt(password: String) throws -> Data {
    let derivedKey: Data
    switch crypto.kdf {
    case "scrypt":
      let scrypt = Scrypt(params: crypto.kdfParams)
      derivedKey = try scrypt.calculate(password: password)
    default:
      throw DecryptError.unsupportedKDF
    }
    
    let mac = KeystoreKey.computeMAC(prefix: derivedKey[derivedKey.count - 16 ..< derivedKey.count], key: crypto.cipherText)
    if mac != crypto.mac {
      throw DecryptError.invalidPassword
    }
    
    let decryptionKey = derivedKey[0...15]
    let decryptedPK: [UInt8]
    switch crypto.cipher {
    case "aes-128-ctr":
      let aesCipher = try AES(key: decryptionKey.bytes, blockMode: CTR(iv: crypto.cipherParams.iv.bytes), padding: .noPadding)
      decryptedPK = try aesCipher.decrypt(crypto.cipherText.bytes)
    case "aes-128-cbc":
      let aesCipher = try AES(key: decryptionKey.bytes, blockMode: CBC(iv: crypto.cipherParams.iv.bytes), padding: .noPadding)
      decryptedPK = try aesCipher.decrypt(crypto.cipherText.bytes)
    default:
      throw DecryptError.unsupportedCipher
    }
    
    return Data(bytes: decryptedPK)
  }
  
  static func computeMAC(prefix: Data, key: Data) -> Data {
    var data = Data(capacity: prefix.count + key.count)
    data.append(prefix)
    data.append(key)
    return data.sha3(.keccak256)
  }

}

public enum DecryptError: Error {
  case unsupportedKDF
  case unsupportedCipher
  case invalidCipher
  case invalidPassword
}

public enum EncryptError: Error {
  case invalidMnemonic
}

extension KeystoreKey: Codable {
  
  enum CodingKeys: String, CodingKey {
    case address
    case id
    case crypto
    case version
  }
  
  enum UppercaseCodingKeys: String, CodingKey {
    case crypto = "Crypto"
  }
  
  public init(from decoder: Decoder) throws {
    let values = try decoder.container(keyedBy: CodingKeys.self)
    let altValues = try decoder.container(keyedBy: UppercaseCodingKeys.self)
    
    id = try values.decode(String.self, forKey: .id)
    if let crypto = try? values.decode(KeystoreKeyHeader.self, forKey: .crypto) {
      self.crypto = crypto
    } else {
      // Workaround for myEtherWallet files
      self.crypto = try altValues.decode(KeystoreKeyHeader.self, forKey: .crypto)
    }
    version = try values.decode(Int.self, forKey: .version)
    address = try values.decodeIfPresent(String.self, forKey: .address)
  }
  
  public func encode(to encoder: Encoder) throws {
    var container = encoder.container(keyedBy: CodingKeys.self)
    try container.encode(id, forKey: .id)
    try container.encodeIfPresent(address, forKey: .address)
    try container.encode(crypto, forKey: .crypto)
    try container.encode(version, forKey: .version)
  }
  
}

private extension String {
  func drop0x() -> String {
    if hasPrefix("0x") {
      return String(dropFirst(2))
    }
    return self
  }
}
