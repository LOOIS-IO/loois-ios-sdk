//
//  TransactionSignatureBuilderSpec.swift
//  LooisKitTests
//
//  Created by Daven on 2018/8/7.
//  Copyright © 2018年 Loois. All rights reserved.
//

import Foundation
import Quick
import Nimble
import TrustCore
import BigInt
@testable import LooisKit

final class TransactionSignatureBuilderSpec: QuickSpec {
  
  override func spec() {
    
    let timeout = 10.0
    
    var keystore: EtherKeystore!
    
    var wallet: Wallet!
    
    beforeSuite {
      keystore = EtherKeystore(keysSubfolder: "/keystore_test_builder")
      if keystore.wallets.count == 0 {
        let words = "cause water picnic laugh magnet subway dance pill nominee gorilla output blind".components(separatedBy: " ")
        let password = "12345678"
        keystore.buildWallet(type: .mnemonic(words: words, newPassword: password), completion: { (result) in
          wallet = result.value
        })
      } else {
        wallet = keystore.wallets.first
      }
    }
    
    describe("Build Signature") {
      
      beforeEachWithMetadata({ (meta) in
        print("-------\(meta?.exampleIndex ?? -1)-------", wallet?.identifier ?? "wallet is being prepared")
        expect(wallet).toEventuallyNot(beNil(), timeout: timeout)
        
        if let address = wallet.address {
          expect(keystore.wallet(for: address)?.identifier).to(equal(wallet.identifier))
        }
      })
      
      it("Invalid args will throw error", closure: {
        
        let project = AirdropType.neo
        let owner = "0xf493d55491EaD875cC"
        let gasPrice = BigInt(1_000_000_000_000)
        let gasLimit = BigInt(60_000)
        let nonce = BigInt(100)
        let contractAddress = "0xc02aaa34f27ead9083c756cc2"
        
        let builder = TransactionSignatureBuilder.bind(project: project, owner: owner, gasPrice: gasPrice, gasLimit: gasLimit, nonce: nonce, contractAddress: contractAddress)
        
        expect(expression: { () -> String? in
          return try builder.build(with: wallet, password: "12345678")
        }).to(throwError(SignBuildError.invalidSignArguments))
        
      })
      
      it("airdrop bind", closure: {
        
        let project = AirdropType.neo
        let owner = "感觉我"
        let gasPrice = BigInt(20_000_000_000)
        let gasLimit = BigInt(200_000)
        let nonce = BigInt(597)
        let contractAddress = "0xbf78B6E180ba2d1404c92Fc546cbc9233f616C42"
        
        let builder = TransactionSignatureBuilder.bind(project: project, owner: owner, gasPrice: gasPrice, gasLimit: gasLimit, nonce: nonce, contractAddress: contractAddress)
        
        expect(expression: { () -> String? in
          return try builder.build(with: wallet, password: "12345678")
        }).to(equal("f8ec8202558504a817c80083030d4094bf78b6e180ba2d1404c92fc546cbc9233f616c4280b884ca02620a000000000000000000000000000000000000000000000000000000000000000100000000000000000000000000000000000000000000000000000000000000400000000000000000000000000000000000000000000000000000000000000009e6849fe8a789e6889100000000000000000000000000000000000000000000001ba03c417f788608ac1183d0cdd332a433d57b134a51a705bcb9cbad785a3b8587eba04596e270db352cf7163aaaf16a28f0354d51970f389a99b667f31e314be74220"))
        
      })
      
      it("transfer ETH", closure: {
        
        let amount = BigInt(1_000_000_000_000_000)
        let gasPrice = BigInt(12_356_100_000)
        let gasLimit = BigInt(24_000)
        let nonce = BigInt(597)
        let toAddress = "0xf494B631F83909dd19BA55a7e3d55491EaD875cC"
        
        let builder = TransactionSignatureBuilder.transferETH(amount: amount, gasPrice: gasPrice, gasLimit: gasLimit, nonce: nonce, toAddress: toAddress)
        
        expect(expression: { () -> String? in
          return try builder.build(with: wallet, password: "12345678")
        }).to(equal("f86f8202558502e07b1fa0825dc094f494b631f83909dd19ba55a7e3d55491ead875cc87038d7ea4c680008230781ba0e8c4e8477f2a47f7db5571cbd3674860acff6e702c3af5162b9189b0f8d3d9d4a01aa1c978d6cfe37bb18a598363c206d2b29dc6829a4e77b6e0366c33f43e32f7"))
      })
      
      it("transfer ERC20 token", closure: {
        
        let amount = BigUInt.init("12000000000000000000")
        expect(amount).toNot(beNil())
        let gasPrice = BigInt(4871420000)
        let gasLimit = BigInt(60_000)
        let nonce = BigInt(597)
        let contractAddress = "0xBeB6fdF4ef6CEb975157be43cBE0047B248a8922"
        let toAddress = "0xf494B631F83909dd19BA55a7e3d55491EaD875cC"
        
        let builder = TransactionSignatureBuilder.transferERC20Token(amount: amount!, gasPrice: gasPrice, gasLimit: gasLimit, nonce: nonce, contractAddress: contractAddress, toAddress: toAddress)
        
        expect(expression: { () -> String? in
          return try builder.build(with: wallet, password: "12345678")
        }).to(equal("f8ab8202558501225bf86082ea6094beb6fdf4ef6ceb975157be43cbe0047b248a892280b844a9059cbb000000000000000000000000f494b631f83909dd19ba55a7e3d55491ead875cc000000000000000000000000000000000000000000000000a688906bd8b000001ba093242159a828cfdc2f408a156259cc1ec5b9f05a2041c6b68da796cd34720ceca07dc2738164b1174c7ceb3da26e1e124fc4abd97824eb450f0b2b6b99b3acc7dc"))
      })
      
      xit("weth to eth", closure: {
        
        let amount = BigUInt(12000000)
        expect(amount).toNot(beNil())
        let gasPrice = BigInt(4871420000)
        let gasLimit = BigInt(60_000)
        let nonce = BigInt(597)
        let contractAddress = ""
        
        let builder = TransactionSignatureBuilder.wethToEth(amount: amount, gasPrice: gasPrice, gasLimit: gasLimit, nonce: nonce, contractAddress: contractAddress)
        
        expect(expression: { () -> String? in
          return try builder.build(with: wallet, password: "12345678")
        }).to(equal(""))
      })
      
      xit("eth to weth", closure: {
        
        let amount = BigInt(12000000)
        expect(amount).toNot(beNil())
        let gasPrice = BigInt(4871420000)
        let gasLimit = BigInt(60_000)
        let nonce = BigInt(597)
        let contractAddress = ""
        
        let builder = TransactionSignatureBuilder.ethToWeth(amount: amount, gasPrice: gasPrice, gasLimit: gasLimit, nonce: nonce, contractAddress: contractAddress)
        
        expect(expression: { () -> String? in
          return try builder.build(with: wallet, password: "12345678")
        }).to(equal(""))
      })
      
      xit("approve", closure: {
        
      })
      
      xit("cancel order", closure: {
        
      })
      
      xit("cancel all order", closure: {
        
      })
      
      xit("cancel orders by token pair", closure: {
        
      })
      
    }
    
  }
  
}
