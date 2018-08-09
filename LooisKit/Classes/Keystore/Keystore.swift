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
  
  var keysDirectory: URL { get }
  
  func buildWallet(type: BuildType, completion: @escaping (Result<Wallet, KeystoreError>) -> Void)
  func exportWallet(type: ExportType, completion: @escaping (Result<String, KeystoreError>) -> Void)
  
}
