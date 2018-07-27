//
//  RawTransaction.swift
//  LooisKit
//
//  Created by Daven on 2018/7/24.
//  Copyright © 2018年 Loois. All rights reserved.
//

import Foundation
import BigInt
import TrustCore

public struct RawTransaction: SignTransaction {
  public let value: BigInt
  public let to: EthereumAddress?
  public let nonce: BigInt
  public let data: Data
  public let gasPrice: BigInt
  public let gasLimit: BigInt
  
  public init(value: BigInt, to: EthereumAddress?, nonce: BigInt, gasPrice: BigInt, gasLimit: BigInt, rawEncoder: FunctionRawEncoder) {
    self.value = value
    self.to = to
    self.nonce = nonce
    self.gasPrice = gasPrice
    self.gasLimit = gasLimit
    self.data = rawEncoder.encodedData
  }
}
