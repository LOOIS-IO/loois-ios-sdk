//
//  ExportType.swift
//  LooisKit
//
//  Created by Daven on 2018/7/21.
//  Copyright © 2018年 Loois. All rights reserved.
//

import Foundation
import TrustKeystore

/// 钱包导出类型
public enum ExportType {
  case keystore(wallet: Wallet, password: String, newPassword: String)
  case privateKey(wallet: Wallet, password: String)
  case mnemonic(wallet: Wallet, password: String)
}
