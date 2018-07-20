//
//  Time.swift
//  LooisKit
//
//  Created by Daven on 2018/7/20.
//  Copyright © 2018年 Loois. All rights reserved.
//

@discardableResult
func time<Result>(name: StaticString = #function, line: Int = #line, _ f: () -> Result) -> Result {
  let startTime = DispatchTime.now()
  let result = f()
  let endTime = DispatchTime.now()
  let diff = Double(endTime.uptimeNanoseconds - startTime.uptimeNanoseconds) / 1_000_000_000 as Double
  print("\(name) (line \(line)): \(diff) sec")
  return result
}
