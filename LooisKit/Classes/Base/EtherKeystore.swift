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
      DispatchQueue.global(qos: .userInitiated).async {
        let wallet = try! self.keyStore.createWallet(
          password: newPassword,
          derivationPaths: [Coin.ethereum.derivationPath(at: 0)]
        )
        DispatchQueue.main.async {
          completion(.success(wallet))
        }
      }
    case let .keystore(string, password, newPassword):
      DispatchQueue.global(qos: .userInitiated).async {
        let result = self.importKeystore(value: string, password: password, newPassword: newPassword)
        DispatchQueue.main.async {
          switch result {
          case .success(let wallet):
            completion(.success(wallet))
          case .failure(let error):
            completion(.failure(error))
          }
        }
      }
    case let .mnemonic(words, newPassword):
      let string = words.map { String($0) }.joined(separator: " ")
      if !Crypto.isValid(mnemonic: string) {
        return completion(.failure(KeystoreError.invalidMnemonicPhrase))
      }
      do {
        let wallet = try keyStore.import(mnemonic: string, passphrase: "", encryptPassword: newPassword, derivationPath: Coin.ethereum.derivationPath(at: 0))
        completion(.success(wallet))
      } catch {
        return completion(.failure(KeystoreError.duplicateAccount))
      }
    case let .privateKey(privateKey, newPassword):
      guard let data = Data(hexString: privateKey),
        let privateKeyData = PrivateKey(data: data) else {
        completion(.failure(KeystoreError.invalidPrivateKey))
        return
      }
      DispatchQueue.global(qos: .userInitiated).async {
        do {
          let wallet = try self.keyStore.import(privateKey: privateKeyData, password: newPassword, coin: .ethereum)
          DispatchQueue.main.async {
            completion(.success(wallet))
          }
        } catch {
          DispatchQueue.main.async {
            completion(.failure(KeystoreError.failedToImportPrivateKey))
          }
        }
      }
    }
  }
  
  public func exportWallet() {
    
  }
  
  fileprivate func importKeystore(value: String, password: String, newPassword: String) -> Result<Wallet, KeystoreError> {
    guard let data = value.data(using: .utf8) else {
      return (.failure(.failedToParseJSON))
    }
    do {
      let wallet = try keyStore.import(json: data, password: password, newPassword: newPassword, coin: .ethereum)
      return .success(wallet)
    } catch {
      if case KeyStore.Error.accountAlreadyExists = error {
        return .failure(.duplicateAccount)
      } else {
        return .failure(.failedToImport(error))
      }
    }
  }
  
}
