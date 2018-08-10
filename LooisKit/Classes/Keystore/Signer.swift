//
//  Signer.swift
//  LooisKit
//
//  Created by Deven on 2018/7/17.
//  Copyright © 2018年 Loois. All rights reserved.
//

import Foundation
import BigInt
import CryptoSwift
import TrustCore
import Result

public protocol SignTransaction {
  var value: BigInt { get }
  var to: EthereumAddress? { get }
  var nonce: BigInt { get }
  var data: Data { get }
  var gasPrice: BigInt { get }
  var gasLimit: BigInt { get }
}

protocol Signer {
  func hash(transaction: SignTransaction) -> Data
  func values(transaction: SignTransaction, signature: Data) -> (r: BigInt, s: BigInt, v: BigInt)
  
  func sign(transaction: SignTransaction, wallet: Wallet, password: String) -> Result<Data, KeystoreError>
}
