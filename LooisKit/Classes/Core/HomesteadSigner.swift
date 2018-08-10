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
import Result

public struct HomesteadSigner: Signer {
  
  public init() {}
  
  public func sign(transaction: SignTransaction, wallet: Wallet, password: String) -> Result<Data, KeystoreError> {
    guard let (r, s, v) = signValues(transaction: transaction, wallet: wallet, password: password) else {
      return .failure(.failedToSignTransaction)
    }
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
  }
  
  func signValues(transaction: SignTransaction, wallet: Wallet, password: String) -> (r: BigInt, s: BigInt, v: BigInt)? {
    do {
      let hash = self.hash(transaction: transaction)
      let signature = try wallet.sign(hash: hash, password: password)
      let (r, s, v) = values(transaction: transaction, signature: signature)
      return (r, s, v)
    } catch {
      return nil
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
