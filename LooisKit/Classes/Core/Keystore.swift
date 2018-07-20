//
//  Keystore.swift
//  LooisKit
//
//  Created by Daven on 2018/7/18.
//  Copyright © 2018年 Loois. All rights reserved.
//

import Foundation
import TrustKeystore
import Result

protocol Keystore {
  
  typealias Completion = (Result<Wallet, KeystoreError>) -> Void
  
  var keysDirectory: URL { get }
  
  func buildWallet(type: BuildType, completion: @escaping Completion)
  func exportWallet()
  
}
