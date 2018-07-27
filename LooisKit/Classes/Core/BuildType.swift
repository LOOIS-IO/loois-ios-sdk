//
//  BuildType.swift
//  LooisKit
//
//  Created by Daven on 2018/7/19.
//  Copyright © 2018年 Loois. All rights reserved.
//

import Foundation

/// 钱包构建类型
public enum BuildType {
  case create(newPassword: String)
  case keystore(string: String, password: String, newPassword: String)
  case privateKey(privateKey: String, newPassword: String)
  case mnemonic(words: [String], newPassword: String)
}
