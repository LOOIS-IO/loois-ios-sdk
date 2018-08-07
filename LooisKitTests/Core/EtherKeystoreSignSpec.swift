//
//  EtherKeystoreSignSpec.swift
//  LooisKitTests
//
//  Created by Daven on 2018/7/24.
//  Copyright © 2018年 Loois. All rights reserved.
//

import Foundation
import Quick
import Nimble
import TrustCore
import TrustKeystore
import BigInt
@testable import LooisKit

final class EtherKeystoreSignSpec: QuickSpec {
  
  override func spec() {
    
    let timeout = 10.0
    
    var keystore: EtherKeystore!
    
    var wallet: Wallet!
    
    beforeSuite {
      keystore = EtherKeystore(keysSubfolder: "/keystore_test_sign")
      
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
    
    describe("Sign Transaction") {
      
      beforeEachWithMetadata({ (meta) in
        print("-------\(meta?.exampleIndex ?? -1)-------", wallet?.identifier ?? "wallet is being prepared")
        expect(wallet).toEventuallyNot(beNil(), timeout: timeout)
      })
      
      it("sign transfer token data", closure: {
        let contractAddress = EthereumAddress(string: "0xc02aaa39b223fe8d0a0e5c4f27ead9083c756cc2") // WETH
        let encoder = FunctionRawEncoder.transfer(to: EthereumAddress(string: "0xf494B631F83909dd19BA55a7e3d55491EaD875cC")!,
                                                  amount: 1_000_000_000_000_000)
        
        let st = RawTransaction(nonce: 539, gasPrice: 5140490000, gasLimit: 60000, value: 0, to: contractAddress, data: encoder.encodedData)

        let signed = HomesteadSigner().sign(transaction: st, wallet: wallet, password: "12345678")
        expect(signed.error).to(beNil())
        expect(signed.value?.hexString) == "f8ab82021b85013265a71082ea6094c02aaa39b223fe8d0a0e5c4f27ead9083c756cc280b844a9059cbb000000000000000000000000f494b631f83909dd19ba55a7e3d55491ead875cc00000000000000000000000000000000000000000000000000038d7ea4c680001ba066b3c55448636457b418ae8de34d06a4bb3444197e6007227ac7001852c82fcea0344121903f947ae240d3ce26c61325615de3e7731756a431c2703117b3fd69ed"
      })
    }
    
  }
  
}
