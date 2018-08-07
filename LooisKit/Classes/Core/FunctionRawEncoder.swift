//
//  FunctionRawEncoder.swift
//  LooisKit
//
//  Created by Daven on 2018/7/24.
//  Copyright © 2018年 Loois. All rights reserved.
//

import Foundation
import BigInt
import TrustCore

public enum FunctionRawEncoder {
  case bind(projectId: UInt, owner: String)
  case getBindingAddress(owner: EthereumAddress, projectId: UInt8)
  case transfer(to: EthereumAddress, amount: BigUInt)
  case withdraw(amount: BigUInt)
  case deposit
  case approve(address: EthereumAddress, amount: BigUInt)
  case cancelAllOrders(timestamp: BigUInt)
  case cancelAllOrdersByTradingPair(tokenAAddress: EthereumAddress, tokenBAddress: EthereumAddress, timestamp: BigUInt)
  
  public var function: Function {
    switch self {
    case .bind: return Function(name: "bind", parameters: [.uint(bits: 8), .string])
    case .getBindingAddress: return Function(name: "getBindingAddress", parameters: [.address, .uint(bits: 8)])
    case .transfer: return Function(name: "transfer", parameters: [.address, .uint(bits: 256)])
    case .withdraw: return Function(name: "withdraw", parameters: [.uint(bits: 256)])
    case .deposit: return Function(name: "deposit", parameters: [])
    case .approve: return Function(name: "approve", parameters: [.address, .uint(bits: 256)])
    case .cancelAllOrders: return Function(name: "cancelAllOrders", parameters: [.uint(bits: 256)])
    case .cancelAllOrdersByTradingPair: return Function(name: "cancelAllOrdersByTradingPair", parameters: [.address, .address, .uint(bits: 256)])
    }
  }
  
  public var arguments: [Any] {
    switch self {
    case let .bind(projectId, owner): return [projectId, owner]
    case let .getBindingAddress(owner, projectId): return [owner, projectId]
    case let .transfer(to, amount): return [to, amount]
    case let .withdraw(amount): return [amount]
    case .deposit: return []
    case let .approve(address, amount): return [address, amount]
    case let .cancelAllOrders(timestamp): return [timestamp]
    case let .cancelAllOrdersByTradingPair(tokenAAddress, tokenBAddress, timestamp): return [tokenAAddress, tokenBAddress, timestamp]
    }
  }
  
  public var encodedData: Data {
    let encoder = ABIEncoder()
    try! encoder.encode(function: function, arguments: arguments)
    return encoder.data
  }
}
