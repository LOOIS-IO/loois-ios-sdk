//
//  EtherKeystoreManagementSpec.swift
//  LooisKitTests
//
//  Created by Daven on 2018/8/9.
//  Copyright © 2018年 Loois. All rights reserved.
//

import Foundation
import Quick
import Nimble
import TrustCore
@testable import LooisKit

final class EtherKeystoreManagementSpec: QuickSpec {
  
  override func spec() {
    
    let timeout = 10.0
    
    var keystore: EtherKeystore!
    
    var wallet: Wallet!
    
    beforeSuite {
      keystore = EtherKeystore(keysSubfolder: "/keystore_test_management")
      
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
    
    describe("manage wallet") {
      
      beforeEachWithMetadata({ (meta) in
        print("-------\(meta?.exampleIndex ?? -1)-------", wallet?.identifier ?? "wallet is being prepared")
        expect(wallet).toEventuallyNot(beNil(), timeout: timeout)
      })
      
      it("update wallet password by using correct password", closure: {
        var res: Bool!
        keystore.update(wallet: wallet, password: "12345678", newPassword: "87654321", completion: { (result) in
          res = result.value
        })
        expect(res).toEventually(beTrue(), timeout: timeout)
        keystore.update(wallet: wallet, password: "87654321", newPassword: "12345678", completion: { (result) in
          res = result.value
        })
        expect(res).toEventually(beTrue(), timeout: timeout)
      })
      
      it("update wallet password by using incorrect password", closure: {
        var error: KeystoreError!
        keystore.update(wallet: wallet, password: "---", newPassword: "87654321", completion: { (result) in
          error = result.error
        })
        expect(error?.localizedDescription).toEventually(equal(KeystoreError.failedToUpdatePassword.localizedDescription), timeout: timeout)
      })
      
      it("delete wallet by using incorrect password", closure: {
        var error: KeystoreError!
        keystore.delete(wallet: wallet, password: "====", completion: { (result) in
          error = result.error
        })
        expect(error?.localizedDescription).toEventually(equal(KeystoreError.failedToDeleteAccount.localizedDescription), timeout: timeout)
      })
      
      it("delete wallet by using correct password", closure: {
        var wallet: Wallet!
        keystore.buildWallet(type: BuildType.create(newPassword: "12345678"), completion: { (result) in
          wallet = result.value
        })
        expect(wallet).toEventuallyNot(beNil(), timeout: timeout)
        var res: Bool!
        keystore.delete(wallet: wallet, password: "12345678", completion: { (result) in
          res = result.value
        })
        expect(res).toEventually(beTrue(), timeout: timeout)
      })
      
    }
  }
}
