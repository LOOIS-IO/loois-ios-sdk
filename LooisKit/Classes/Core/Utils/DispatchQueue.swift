//
//  DispatchQueue.swift
//  LooisKit
//
//  Created by Daven on 2018/7/21.
//  Copyright © 2018年 Loois. All rights reserved.
//

import Foundation

extension DispatchQueue {
  
  public class func executeGlobal<T>(qos: DispatchQoS.QoSClass = .userInitiated,
                                     execute work: @escaping @autoclosure () -> T,
                                     main feedback: @escaping (T) -> Void)
  {
    DispatchQueue.global(qos: qos).async {
      let result = work()
      DispatchQueue.main.async {
        feedback(result)
      }
    }
  }
  
}
