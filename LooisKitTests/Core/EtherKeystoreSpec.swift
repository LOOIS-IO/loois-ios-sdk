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
          
          keystore.buildWallet(type: BuildType.create(newPassword: "123456"), completion: { (result) in
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
            {"address":"15e8523fbffd31d79d359580fca7f2f1e6af5a96","id":"8e434262-d60a-465a-8442-8a9234afcfdf","version":3,"crypto":{"cipher":"aes-128-ctr","cipherparams":{"iv":"e9c24f1cb678691c5df208d8054a0561"},"ciphertext":"7dbd28e37c56ceb14d88b78f94970a22ba4d5ab3549101497f8c57dd6507b84c","kdf":"scrypt","kdfparams":{"dklen":32,"n":4096,"p":6,"r":8,"salt":"a53d135692a50973377d4a66440245e0d1d4e6b4aec51b0282a7f115f3840b60"},"mac":"a5c8869fec59696fd6ee5be8cc72b103e2205865269a585abfc3e79889d43a3a"}}
            """
            let password = "qq123456"
            let newPassword = "12345678"
            keystore.buildWallet(type: BuildType.keystore(string: ksstring, password: password, newPassword: newPassword), completion: { (result) in
              
              expect((result.value?.accounts.first?.address as? EthereumAddress)?.eip55String.lowercased()).to(equal("0x15E8523FBFfD31d79D359580fCA7f2F1e6aF5a96".lowercased()))
              done()
            })
          })
        })
        
        it("valid keystore string and invalid password", closure: {
          
        })
        
        it("invalid keystore string", closure: {
          
        })
        
      })
      
      context("using PrivateKey", {
        
        it("valid private key", closure: {
          
          waitUntil(timeout: timeout, action: { done in
            let privateKey = "ece511be98b696e4e1288b7533eb6f46dd02ef397c859dd1823694c9123c46be"
            let newPassword = "123456"
            keystore.buildWallet(type: BuildType.privateKey(privateKey: privateKey, newPassword: newPassword), completion: { (result) in
              expect((result.value?.accounts.first?.address as? EthereumAddress)?.eip55String.lowercased()).to(equal("0x15E8523FBFfD31d79D359580fCA7f2F1e6aF5a96".lowercased()))
              done()
            })
          })
          
        })
        
      })
      
      context("using Mnemonic Phrase", {
        
        fit("valid words and password", closure: {
          
          let words = "cause water picnic laugh magnet subway dance pill nominee gorilla output blind".components(separatedBy: " ")
          let password = "123456"
          keystore.buildWallet(type: BuildType.mnemonic(words: words, newPassword: password), completion: { (result) in
            expect((result.value?.accounts.first?.address as? EthereumAddress)?.eip55String.lowercased()).to(equal("0xeaEEc75BA0880a44EDC5460E1D91c59A9da6bbC7".lowercased()))
          })
        })
        
        it("valid words and empty password", closure: {
          
        })
        
        it("invalid words", closure: {
          
        })
      })
      
    }
  }
  
}
