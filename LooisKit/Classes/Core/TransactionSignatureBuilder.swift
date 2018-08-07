
//
//  TransactionSignatureBuilder.swift
//  LooisKit
//
//  Created by Daven on 2018/8/6.
//  Copyright © 2018年 Loois. All rights reserved.
//

import Foundation
import BigInt
import TrustCore
import TrustKeystore

public enum SignBuildError: Error {
  case invalidSignArguments
  case signFailed
}

public enum AirdropType: UInt {
  case neo = 1
  case qtum = 2
}

public protocol EncodableOrder {
  var encodedData: Data { get }
}

public enum TransactionSignatureBuilder {
  
  /// 绑定空投
  case bind(project: AirdropType, owner: String, gasPrice: BigInt, gasLimit: BigInt, nonce: BigInt, contractAddress: String)
  /// ETH转账
  case transferETH(amount: BigInt, gasPrice: BigInt, gasLimit: BigInt, nonce: BigInt, toAddress: String)
  /// ERC20 Token转账
  case transferERC20Token(amount: BigUInt, gasPrice: BigInt, gasLimit: BigInt, nonce: BigInt, contractAddress: String, toAddress: String)
  /// WETH兑ETH
  case wethToEth(amount: BigUInt, gasPrice: BigInt, gasLimit: BigInt, nonce: BigInt, contractAddress: String)
  /// ETH兑WETH
  case ethToWeth(amount: BigInt, gasPrice: BigInt, gasLimit: BigInt, nonce: BigInt, contractAddress: String)
  /// 授权
  case approve(amount: BigUInt, gasPrice: BigInt, gasLimit: BigInt, nonce: BigInt, contractAddress: String, delegateAddress: String)
  /// 取消订单
  case cancelOrder(order: EncodableOrder, gasPrice: BigInt, gasLimit: BigInt, nonce: BigInt, contractAddress: String)
  /// 取消所有订单
  case cancelAllOrder(timestamp: TimeInterval, gasPrice: BigInt, gasLimit: BigInt, nonce: BigInt, contractAddress: String)
  /// 按交易对取消订单
  case cancelOrdersByTokenPair(timestamp: TimeInterval, gasPrice: BigInt, gasLimit: BigInt, nonce: BigInt, contractAddress: String, tokenAAddress: String, tokenBAddress: String)
  
  public var transaction: SignTransaction? {
    switch self {
    case let .bind(project, owner, gasPrice, gasLimit, nonce, contractAddress):
      
      guard let contractAddress = EthereumAddress(string: contractAddress) else { return nil }
      
      let encoder = FunctionRawEncoder.bind(projectId: project.rawValue, owner: owner)
      return RawTransaction(nonce: nonce,
                            gasPrice: gasPrice,
                            gasLimit: gasLimit,
                            value: 0,
                            to: contractAddress,
                            data: encoder.encodedData)
      
    case let .transferETH(amount, gasPrice, gasLimit, nonce, toAddress):
      
      guard let toAddress = EthereumAddress(string: toAddress) else { return nil }
      
      return RawTransaction(nonce: nonce,
                            gasPrice: gasPrice,
                            gasLimit: gasLimit,
                            value: amount,
                            to: toAddress,
                            data: "0x".data(using: .utf8)!)
      
      
    case let .transferERC20Token(amount, gasPrice, gasLimit, nonce, contractAddress, toAddress):
      
      guard let toAddress = EthereumAddress(string: toAddress),
        let contractAddress = EthereumAddress(string: contractAddress) else { return nil }
      
      let encoder = FunctionRawEncoder.transfer(to: toAddress, amount: amount)
      return RawTransaction(nonce: nonce,
                            gasPrice: gasPrice,
                            gasLimit: gasLimit,
                            value: 0,
                            to: contractAddress,
                            data: encoder.encodedData)
      
    case let .wethToEth(amount, gasPrice, gasLimit, nonce, contractAddress):
      
      guard let contractAddress = EthereumAddress(string: contractAddress) else { return nil }
      
      let encoder = FunctionRawEncoder.withdraw(amount: amount)
      return RawTransaction(nonce: nonce,
                            gasPrice: gasPrice,
                            gasLimit: gasLimit,
                            value: 0,
                            to: contractAddress,
                            data: encoder.encodedData)
      
    case let .ethToWeth(amount, gasPrice, gasLimit, nonce, contractAddress):
      
      guard let contractAddress = EthereumAddress(string: contractAddress) else { return nil }
      
      let encoder = FunctionRawEncoder.deposit
      return RawTransaction(nonce: nonce,
                            gasPrice: gasPrice,
                            gasLimit: gasLimit,
                            value: amount,
                            to: contractAddress,
                            data: encoder.encodedData)
      
    case let .approve(amount, gasPrice, gasLimit, nonce, contractAddress, delegateAddress):
      
      guard let delegateAddress = EthereumAddress(string: delegateAddress),
        let contractAddress = EthereumAddress(string: contractAddress) else { return nil }
      
      let encoder = FunctionRawEncoder.approve(address: delegateAddress, amount: amount)
      return RawTransaction(nonce: nonce,
                            gasPrice: gasPrice,
                            gasLimit: gasLimit,
                            value: 0,
                            to: contractAddress,
                            data: encoder.encodedData)
      
    case let .cancelOrder(order, gasPrice, gasLimit, nonce, contractAddress):
      
      guard let contractAddress = EthereumAddress(string: contractAddress) else { return nil }
      
      return RawTransaction(nonce: nonce,
                            gasPrice: gasPrice,
                            gasLimit: gasLimit,
                            value: 0,
                            to: contractAddress,
                            data: order.encodedData)
      
    case let .cancelAllOrder(timestamp, gasPrice, gasLimit, nonce, contractAddress):
      
      guard let contractAddress = EthereumAddress(string: contractAddress) else { return nil }
    
      let encoder = FunctionRawEncoder.cancelAllOrders(timestamp: BigUInt(timestamp))
      return RawTransaction(nonce: nonce,
                            gasPrice: gasPrice,
                            gasLimit: gasLimit,
                            value: 0,
                            to: contractAddress,
                            data: encoder.encodedData)
      
    case let .cancelOrdersByTokenPair(timestamp, gasPrice, gasLimit, nonce, contractAddress, tokenAAddress, tokenBAddress):
      
      guard let contractAddress = EthereumAddress(string: contractAddress),
        let tokenAAddress = EthereumAddress(string: tokenAAddress),
        let tokenBAddress = EthereumAddress(string: tokenBAddress) else { return nil }
      
      let encoder = FunctionRawEncoder.cancelAllOrdersByTradingPair(tokenAAddress: tokenAAddress,
                                                                    tokenBAddress: tokenBAddress,
                                                                    timestamp: BigUInt(timestamp))
      return RawTransaction(nonce: nonce,
                            gasPrice: gasPrice,
                            gasLimit: gasLimit,
                            value: 0,
                            to: contractAddress,
                            data: encoder.encodedData)
    }
  }
  
  public func build(with wallet: Wallet, password: String) throws -> String {
    guard let transaction = transaction else {
      throw SignBuildError.invalidSignArguments
    }
    let res = HomesteadSigner().sign(transaction: transaction, wallet: wallet, password: password)
    guard let value = res.value?.hexString, !value.isEmpty else {
      throw SignBuildError.signFailed
    }
    return value
  }
  
  public func buildValues(with wallet: Wallet, password: String) throws -> (r: BigInt, s: BigInt, v: BigInt) {
    guard let transaction = transaction else {
      throw SignBuildError.invalidSignArguments
    }
    guard let res = HomesteadSigner().signValues(transaction: transaction, wallet: wallet, password: password) else {
      throw SignBuildError.signFailed
    }
    return res
  }
  
}
