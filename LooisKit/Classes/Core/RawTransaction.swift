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
  public let nonce: BigInt
  public let gasPrice: BigInt
  public let gasLimit: BigInt
  public let value: BigInt
  public let to: EthereumAddress?
  public let data: Data
  public let functionRaw: Data
}
