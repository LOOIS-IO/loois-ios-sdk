//
//  HomesteadSigner.swift
//  LooisKit
//
//  Created by Daven on 2018/7/24.
//  Copyright © 2018年 Loois. All rights reserved.
//

import Foundation
import BigInt
import CryptoSwift
import TrustCore
import TrustKeystore
import Result

public struct HomesteadSigner: Signer {
  
  public func sign(transaction: SignTransaction, wallet: Wallet, password: String) -> Result<Data, KeystoreError> {
    guard let address = transaction.to else {
      return .failure(.failedToSignTransaction)
    }
    
    let account = Account(wallet: wallet, address: address, derivationPath: Coin.ethereum.derivationPath(at: 0))
    
    do {
      let hash = self.hash(transaction: transaction)
      let signature = try account.sign(hash: hash, password: password)
      let (r, s, v) = values(transaction: transaction, signature: signature)
      let data = RLP.encode([
        transaction.nonce,
        transaction.gasPrice,
        transaction.gasLimit,
        transaction.to?.data ?? Data(),
        transaction.value,
        transaction.data,
        v, r, s,
        ])!
      return .success(data)
    } catch {
      return .failure(.failedToSignTransaction)
    }
  }
  
  func hash(transaction: SignTransaction) -> Data {
    return rlpHash([
      transaction.nonce,
      transaction.gasPrice,
      transaction.gasLimit,
      transaction.to?.data ?? Data(),
      transaction.value,
      transaction.data,
      ])!
  }
  
  func values(transaction: SignTransaction, signature: Data) -> (r: BigInt, s: BigInt, v: BigInt) {
    precondition(signature.count == 65, "Wrong size for signature")
    let r = BigInt(sign: .plus, magnitude: BigUInt(Data(signature[..<32])))
    let s = BigInt(sign: .plus, magnitude: BigUInt(Data(signature[32..<64])))
    let v = BigInt(sign: .plus, magnitude: BigUInt(Data(bytes: [signature[64] + 27])))
    return (r, s, v)
  }
}

func rlpHash(_ element: Any) -> Data? {
  let sha3 = SHA3(variant: .keccak256)
  guard let data = RLP.encode(element) else {
    return nil
  }
  return Data(bytes: sha3.calculate(for: data.bytes))
}
