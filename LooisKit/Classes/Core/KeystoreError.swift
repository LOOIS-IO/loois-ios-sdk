//
//  KeystoreError.swift
//  LooisKit
//
//  Created by Daven on 2018/7/19.
//  Copyright © 2018年 Loois. All rights reserved.
//

public enum KeystoreError: LocalizedError {
  
  case failedToDeleteAccount
  case failedToDecryptKey
  case failedToImport(Error)
  case duplicateAccount
  case failedToSignTransaction
  case failedToUpdatePassword
  case failedToCreateWallet
  case failedToImportPrivateKey
  case failedToParseJSON
  case invalidMnemonicPhrase
  case invalidPrivateKey
  
  public var errorDescription: String? {
    switch self {
    case .failedToDeleteAccount:
      return "Failed to delete account"
    case .failedToDecryptKey:
      return "Could not decrypt key with given passphrase"
    case .failedToImport(let error):
      return error.localizedDescription
    case .duplicateAccount:
      return "You already added this address to wallets"
    case .failedToSignTransaction:
      return "Failed to sign transaction"
    case .failedToUpdatePassword:
      return "Failed to update password"
    case .failedToCreateWallet:
      return "Failed to create wallet"
    case .failedToImportPrivateKey:
      return "Failed to import private key"
    case .failedToParseJSON:
      return "Failed to parse key JSON"
    case .invalidMnemonicPhrase:
      return "Invalid mnemonic phrase"
    case .invalidPrivateKey:
      return "Invalid private key"
    }
  }
  
}
