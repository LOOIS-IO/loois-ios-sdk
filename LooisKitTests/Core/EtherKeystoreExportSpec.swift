//
//  EtherKeystoreExportSpec.swift
//  LooisKitTests
//
//  Created by Daven on 2018/7/21.
//  Copyright © 2018年 Loois. All rights reserved.
//

import Foundation
import Quick
import Nimble
import TrustCore
import TrustKeystore
@testable import LooisKit

final class EtherKeystoreExportSpec: QuickSpec {
  
  override func spec() {
    
    let timeout = 10.0
    
    var keystore: EtherKeystore!
    
    var wallet: Wallet!
    
    
    beforeSuite {
      keystore = EtherKeystore(keysSubfolder: "/keystore_test_export")
      
      if keystore.wallets.count == 0 {
        let words = "length ball music side ripple wide armor army panel message crime garage".components(separatedBy: " ")
        let password = "12345678"
        keystore.buildWallet(type: .mnemonic(words: words, newPassword: password), completion: { (result) in
          wallet = result.value
        })
      } else {
        wallet = keystore.wallets.first
      }
    }

    describe("export wallet") {
      
      beforeEachWithMetadata({ (meta) in
        print("-------\(meta?.exampleIndex ?? -1)-------", wallet?.identifier ?? "wallet is being prepared")
        expect(wallet).toEventuallyNot(beNil(), timeout: timeout)
      })
      
      it("private key by using correct password", closure: {
        var pk: String!
        keystore.exportWallet(type: .privateKey(wallet: wallet, password: "12345678"), completion: { (result) in
          pk = result.value
        })
        expect(pk).toEventuallyNot(beNil(), timeout: timeout)
        
        var newWallet: Wallet!
        keystore.buildWallet(type: .privateKey(privateKey: pk, newPassword: "111222"), completion: { (result) in
          newWallet = result.value
        })
        expect(newWallet).toEventuallyNot(beNil(), timeout: timeout)
        expect(newWallet.accounts.first?.address.data.hexString) == wallet.accounts.first?.address.data.hexString
      })
      
      it("private key by using incorrect password", closure: {
        var error: KeystoreError!
        keystore.exportWallet(type: .privateKey(wallet: wallet, password: "23"), completion: { (result) in
          error = result.error
        })
        expect(error).toEventuallyNot(beNil(), timeout: timeout)
        expect(error.localizedDescription).to(equal(KeystoreError.failedToDecryptKey.localizedDescription))
      })
      
      fit("keystore string by using correct password", closure: {
        var ksstring: String?
        keystore.exportWallet(type: .keystore(wallet: wallet, password: "12345678", newPassword: "11223344"), completion: { (result) in
          ksstring = result.value
          if let error = result.error {
            print(error.localizedDescription)
          }
        })
        expect(ksstring).toEventuallyNot(beNil(), timeout: timeout)

        var newWallet: Wallet?
        keystore.buildWallet(type: .keystore(string: ksstring!, password: "11223344", newPassword: "22334455"), completion: { (result) in
          newWallet = result.value
          if let error = result.error {
            print(error.localizedDescription)
          }
        })
        expect(newWallet).toEventuallyNot(beNil(), timeout: timeout)
        expect(newWallet?.accounts.first?.address.data.hexString) == wallet.accounts.first?.address.data.hexString
      })
      
      it("keystore string by using incorrect password", closure: {
        var error: KeystoreError!
        keystore.exportWallet(type: .keystore(wallet: wallet, password: "323", newPassword: "11223344"), completion: { (result) in
          error = result.error
        })
        expect(error).toEventuallyNot(beNil(), timeout: timeout)
        expect(error.localizedDescription).to(equal(KeystoreError.failedToDecryptKey.localizedDescription))
      })
      
      it("mnenomic words by using correct password", closure: {
        var mnemonic: String!
        keystore.exportWallet(type: .mnemonic(wallet: wallet, password: "12345678"), completion: { (result) in
          mnemonic = result.value
        })
        expect(mnemonic).toEventuallyNot(beNil(), timeout: timeout)
        expect(mnemonic).toNot(beEmpty())
      })
      
      it("mnenomic words by using incorrect password", closure: {
        var error: KeystoreError!
        keystore.exportWallet(type: .mnemonic(wallet: wallet, password: "2343"), completion: { (result) in
          error = result.error
        })
        expect(error).toEventuallyNot(beNil(), timeout: timeout)
        expect(error.localizedDescription).to(equal(KeystoreError.failedToDecryptKey.localizedDescription))
      })
      
    }
  }
  
}
