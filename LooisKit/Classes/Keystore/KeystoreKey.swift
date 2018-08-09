//
//  KeystoreKey.swift
//  LooisKit
//
//  Created by Daven on 2018/8/8.
//  Copyright © 2018年 Loois. All rights reserved.
//

import Foundation
import TrustKeystore

struct KeystoreKey {
  
  var id: String?
  
  var address: String?
  
  var crypto: KeystoreKeyHeader
  
  var version = 3
  
  init(key: TrustKeystore.KeystoreKey) {
    id = key.id
    address = key.address
    crypto = key.crypto
  }
  
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
