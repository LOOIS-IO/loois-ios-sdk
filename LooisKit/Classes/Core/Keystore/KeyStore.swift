//
//  KeyStore+Loois.swift
//  LooisKit
//
//  Created by Daven on 2018/8/8.
//  Copyright © 2018年 Loois. All rights reserved.
//

import Foundation
import TrustCore

/// Manages directories of key and wallet files and presents them as accounts.
public final class KeyStore {
  /// The key file directory.
  public let keyDirectory: URL
  
  /// List of wallets.
  public private(set) var wallets = [Wallet]()
  
  /// Creates a `KeyStore` for the given directory.
  public init(keyDirectory: URL) throws {
    self.keyDirectory = keyDirectory
    try load()
  }
  
  private func load() throws {
    let fileManager = FileManager.default
    try? fileManager.createDirectory(at: keyDirectory, withIntermediateDirectories: true, attributes: nil)
    
    let accountURLs = try fileManager.contentsOfDirectory(at: keyDirectory, includingPropertiesForKeys: [], options: [.skipsHiddenFiles])
    for url in accountURLs {
      do {
        let key = try KeystoreKey(contentsOf: url)
        let wallet = Wallet(keyURL: url, key: key)
        wallets.append(wallet)
      } catch {
        // Ignore invalid keys
      }
    }
  }
  
  public func getWallet(for address: String) -> Wallet? {
    return wallets.filter { $0.address == address }.first
  }
  
  /// Creates a new wallet.
  public func createWallet(password: String) throws -> Wallet {
    let mnemonic = Crypto.generateMnemonic(strength: 128)
    return try self.import(mnemonic: mnemonic, encryptPassword: password)
  }
  
  /// Imports a wallet.
  ///
  /// - Parameters:
  ///   - mnemonic: wallet's mnemonic phrase
  ///   - passphrase: wallet's password
  ///   - encryptPassword: password to use for encrypting
  /// - Returns: new account
  public func `import`(mnemonic: String, passphrase: String = "", encryptPassword: String, derivationPath: DerivationPath = Coin.ethereum.derivationPath(at: 0)) throws -> Wallet {
    if !Crypto.isValid(mnemonic: mnemonic) {
      throw Error.invalidMnemonic
    }
    let hdWallet = HDWallet(mnemonic: mnemonic, passphrase: passphrase)
    let privateKey = hdWallet.getKey(at: derivationPath)
    return try self.import(privateKey: privateKey, password: encryptPassword)
  }
  
  /// Imports an encrypted JSON key.
  ///
  /// - Parameters:
  ///   - key: key to import
  ///   - password: key password
  ///   - newPassword: password to use for the imported key
  /// - Returns: new account
  public func `import`(json: Data, password: String, newPassword: String) throws -> Wallet {
    let key = try JSONDecoder().decode(KeystoreKey.self, from: json)
    guard let address = key.address, getWallet(for: address) != nil else {
      throw Error.accountAlreadyExists
    }
    var privateKeyData = try key.decrypt(password: password)
    defer {
      privateKeyData.clear()
    }
    guard let privateKey = PrivateKey(data: privateKeyData) else {
      throw Error.invalidKey
    }
    return try self.import(privateKey: privateKey, password: newPassword)
  }
  
  /// Imports a private key.
  ///
  /// - Parameters:
  ///   - privateKey: private key to import
  ///   - password: password to use for the imported private key
  /// - Returns: new wallet
  public func `import`(privateKey: PrivateKey, password: String) throws -> Wallet {
    let address = privateKey.publicKey(for: .ethereum).address
    guard getWallet(for: address.data.hexString) == nil else {
        throw Error.accountAlreadyExists
    }
    let newKey = try KeystoreKey(password: password, key: privateKey)
    let url = makeAccountURL(for: address)
    let wallet = Wallet(keyURL: url, key: newKey)
    wallets.append(wallet)
    
    try save(wallet: wallet, in: keyDirectory)
    
    return wallet
  }
  
  /// Exports a wallet as JSON data.
  ///
  /// - Parameters:
  ///   - wallet: wallet to export
  ///   - password: account password
  ///   - newPassword: password to use for exported key
  /// - Returns: encrypted JSON key
  func export(wallet: Wallet, password: String, newPassword: String) throws -> Data {
    var privateKeyData = try exportPrivateKey(wallet: wallet, password: password)
    defer {
      privateKeyData.resetBytes(in: 0 ..< privateKeyData.count)
    }
    guard let privateKey = PrivateKey(data: privateKeyData) else {
      throw Error.invalidKey
    }
    let key = try KeystoreKey(password: newPassword, key: privateKey)
    return try JSONEncoder().encode(key)
  }
  
  /// Exports a wallet as private key data.
  ///
  /// - Parameters:
  ///   - wallet: wallet to export
  ///   - password: account password
  /// - Returns: private key data for encrypted keys or menmonic phrase for HD wallets
  public func exportPrivateKey(wallet: Wallet, password: String) throws -> Data {
    return try wallet.key.decrypt(password: password)
  }
  
  /// Updates the password of an existing account.
  ///
  /// - Parameters:
  ///   - wallet: wallet to update
  ///   - password: current password
  ///   - newPassword: new password
  public func update(wallet: Wallet, password: String, newPassword: String) throws {
    guard let index = wallets.index(of: wallet) else {
      fatalError("Missing wallet")
    }
    
    var privateKeyData = try wallet.key.decrypt(password: password)
    defer {
      privateKeyData.resetBytes(in: 0 ..< privateKeyData.count)
    }
    
    guard let privateKey = PrivateKey(data: privateKeyData) else {
      throw Error.invalidKey
    }
    wallets[index].key = try KeystoreKey(password: newPassword, key: privateKey)
  }
  
  /// Deletes an account including its key if the password is correct.
  public func delete(wallet: Wallet, password: String) throws {
    guard let index = wallets.index(of: wallet) else {
      fatalError("Missing wallet")
    }
    
    var privateKey = try wallet.key.decrypt(password: password)
    defer {
      privateKey.resetBytes(in: 0..<privateKey.count)
    }
    wallets.remove(at: index)
    
    try FileManager.default.removeItem(at: wallet.keyURL)
  }
  
  // MARK: Helpers
  
  private func makeAccountURL(for address: Address) -> URL {
    return keyDirectory.appendingPathComponent(generateFileName(identifier: address.data.hexString))
  }
  
  private func makeAccountURL() -> URL {
    return keyDirectory.appendingPathComponent(generateFileName(identifier: UUID().uuidString))
  }
  
  /// Saves the account to the given directory.
  private func save(wallet: Wallet, in directory: URL) throws {
    try save(key: wallet.key, to: wallet.keyURL)
  }
  
  /// Generates a unique file name for an address.
  func generateFileName(identifier: String, date: Date = Date(), timeZone: TimeZone = .current) -> String {
    // keyFileName implements the naming convention for keyfiles:
    // UTC--<created_at UTC ISO8601>-<address hex>
    return "UTC--\(filenameTimestamp(for: date, in: timeZone))--\(identifier)"
  }
  
  private func filenameTimestamp(for date: Date, in timeZone: TimeZone = .current) -> String {
    var tz = ""
    let offset = timeZone.secondsFromGMT()
    if offset == 0 {
      tz = "Z"
    } else {
      tz = String(format: "%03d00", offset/60)
    }
    
    let components = Calendar(identifier: .iso8601).dateComponents(in: timeZone, from: date)
    return String(format: "%04d-%02d-%02dT%02d-%02d-%02d.%09d%@", components.year!, components.month!, components.day!, components.hour!, components.minute!, components.second!, components.nanosecond!, tz)
  }
  
  private func save(key: KeystoreKey, to url: URL) throws {
    let json = try JSONEncoder().encode(key)
    try json.write(to: url, options: [.atomicWrite])
  }
}
