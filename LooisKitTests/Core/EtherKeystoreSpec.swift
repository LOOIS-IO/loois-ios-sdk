//
//  EtherKeystoreSpec.swift
//  LooisKitTests
//
//  Created by Daven on 2018/7/20.
//  Copyright © 2018年 Loois. All rights reserved.
//

import Foundation
import Quick
import Nimble
import TrustCore
import TrustKeystore
@testable import LooisKit

final class EtherKeystoreSpec: QuickSpec {
  
  override func spec() {
    
    let timeout = 1000.0
    
    var keystore: EtherKeystore!
    
    beforeSuite {
      keystore = EtherKeystore(keysSubfolder: "/keystore_test")
    }
    
    describe("check out keyStore instance") {
      it("instance alloc", closure: {
        expect(keystore.keyStore).toNot(beNil())
      })
    }
    
    describe("create wallet") {
      it("create wallet use password", closure: {
        waitUntil(timeout: timeout, action: { done in
          
          keystore.buildWallet(type: .create(newPassword: "123456"), completion: { (result) in
            expect(result.value).toNot(beNil())
            expect(result.value?.accounts).toNot(beNil())
            expect((result.value?.accounts.first?.address as? EthereumAddress)?.eip55String).toNot(beNil())
            done()
          })
        })
      })
    }
    
    describe("import wallet") {
      
      context("using Keystore", {
        
        it("valid keystore string and password", closure: {
          
          waitUntil(timeout: timeout, action: { done in
            let ksstring = """
            {"address":"f494B631F83909dd19BA55a7e3d55491EaD875cC","crypto":{"cipher":"aes-128-ctr","cipherparams":{"iv":"1816bf36f998d1a44d4ca07ecbb30312"},"ciphertext":"1f0dbff4e58a1753c8eb098a805b59a9ddd4db65d5210e8a901044f3d5741d90","kdf":"scrypt","kdfparams":{"dklen":32,"n":4096,"p":6,"r":8,"salt":"4d4c93b93565541fc69ce8a34ab7f35e3fedababebfa0c96dcee8861fa1ef9f8"},"mac":"30a1e33ebb437a21d9028cca74f5c1c7f9f7b98d7fdfb943dcbac12dbf76b0aa"},"id":"febb384a-a312-4679-b8a1-06207d941f84","version":3}
            """
            let password = "qq112233"
            let newPassword = "12345678"
            keystore.buildWallet(type: .keystore(string: ksstring, password: password, newPassword: newPassword), completion: { (result) in
              
              expect((result.value?.accounts.first?.address as? EthereumAddress)?.eip55String.lowercased()).to(equal("0xf494B631F83909dd19BA55a7e3d55491EaD875cC".lowercased()))
              done()
            })
          })
        })
        
        it("valid keystore stfring and invalid password", closure: {
          
          waitUntil(timeout: timeout, action: { done in
            let ksstring = """
            {"address":"f494B631F83909dd19BA55a7e3d55491EaD875cC","crypto":{"cipher":"aes-128-ctr","cipherparams":{"iv":"1816bf36f998d1a44d4ca07ecbb30312"},"ciphertext":"1f0dbff4e58a1753c8eb098a805b59a9ddd4db65d5210e8a901044f3d5741d90","kdf":"scrypt","kdfparams":{"dklen":32,"n":4096,"p":6,"r":8,"salt":"4d4c93b93565541fc69ce8a34ab7f35e3fedababebfa0c96dcee8861fa1ef9f8"},"mac":"30a1e33ebb437a21d9028cca74f5c1c7f9f7b98d7fdfb943dcbac12dbf76b0aa"},"id":"febb384a-a312-4679-b8a1-06207d941f84","version":3}
            """
            let password = "-------"
            let newPassword = "12345678"
            keystore.buildWallet(type: .keystore(string: ksstring, password: password, newPassword: newPassword), completion: { (result) in
              expect(result.value).to(beNil())
              expect(result.error?.localizedDescription).to(equal(DecryptError.invalidPassword.localizedDescription))
              done()
            })
          })
        })
        
        // other keystore key-value pairs invalid test
        it("invalid keystore params", closure: {
          
          waitUntil(timeout: timeout, action: { done in
            let ksstring = """
            {"address":"f494B631F83909dd19BA55a7e3d55491EaD875cC---","crypto":{"cipher":"aes-128-ctr---","cipherparams":{"iv":"1816bf36f998d1a44d4ca07ecbb30312"},"ciphertext":"1f0dbff4e58a1753c8eb098a805b59a9ddd4db65d5210e8a901044f3d5741d90","kdf":"scrypt---","kdfparams":{"dklen":32,"n":4096,"p":6,"r":8,"salt":"4d4c93b93565541fc69ce8a34ab7f35e3fedababebfa0c96dcee8861fa1ef9f8"},"mac":"30a1e33ebb437a21d9028cca74f5c1c7f9f7b98d7fdfb943dcbac12dbf76b0aa"},"id":"febb384a-a312-4679-b8a1-06207d941f84","version":3}
            """
            let password = "-------"
            let newPassword = "12345678"
            keystore.buildWallet(type: .keystore(string: ksstring, password: password, newPassword: newPassword), completion: { (result) in
              expect(result.value).to(beNil())
              expect(expression: { () -> Void in
                switch result.error {
                case .some(.failedToImport(let error)):
                  if error is DecryptError {
                    print("=-=-=-=--==-=--==-=-", error)
                    throw error
                  }
                default: break
                }
              }).to(throwError())
              done()
            })
          })
        })
        
        it("duplicated account", closure: {
          
        })
        
      })
      
      context("using PrivateKey", {
        
        it("valid private key", closure: {
          
          waitUntil(timeout: timeout, action: { done in
            let privateKey = "e1f46e1ed3344409c2e0ab586cb51909d91a91a9bf11a3816ee3a8a405018b7e"
            let newPassword = "123456"
            keystore.buildWallet(type: .privateKey(privateKey: privateKey, newPassword: newPassword), completion: { (result) in
              expect((result.value?.accounts.first?.address as? EthereumAddress)?.eip55String.lowercased()).to(equal("0xf494B631F83909dd19BA55a7e3d55491EaD875cC".lowercased()))
              done()
            })
          })
        })
        
        it("invalid private key", closure: {
          
          waitUntil(timeout: timeout, action: { done in
            let privateKey = "e1f46e1ed3344409c2e0ab586cb519----1a91a9bf11a3816ee3a8a405018b7e"
            let newPassword = "123456"
            keystore.buildWallet(type: .privateKey(privateKey: privateKey, newPassword: newPassword), completion: { (result) in
              expect(result.value).to(beNil())
              expect(result.error?.localizedDescription).to(equal(KeystoreError.invalidPrivateKey.localizedDescription))
              done()
            })
          })
        })
        
      })
      
      context("using Mnemonic Phrase", {
        
        it("valid words and password", closure: {
          
          let words = "later reveal fault old brand trumpet off usage crash summer manage glow".components(separatedBy: " ")
          let password = "123456"
          keystore.buildWallet(type: .mnemonic(words: words, newPassword: password), completion: { (result) in
            expect((result.value?.accounts.first?.address as? EthereumAddress)?.eip55String.lowercased()).to(equal("0xf494B631F83909dd19BA55a7e3d55491EaD875cC".lowercased()))
          })
        })
        
        it("invalid words", closure: {
          let words = ["sd"]
          let password = "123456"
          keystore.buildWallet(type: .mnemonic(words: words, newPassword: password), completion: { (result) in
            expect(result.value).to(beNil())
            expect(result.error?.localizedDescription).to(equal(KeystoreError.invalidMnemonicPhrase.localizedDescription))
          })
        })
      })
      
    }
  }
  
}
