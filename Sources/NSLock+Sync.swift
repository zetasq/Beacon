//
//  NSLock+Sync.swift
//  Beacon
//
//  Created by Zhu Shengqi on 30/07/2017.
//  Copyright © 2017 zetasq. All rights reserved.
//

import Foundation

extension NSLock {
  internal func synchronized<T>(_ block: () throws -> T) rethrows -> T {
    self.lock()
    
    defer {
      self.unlock()
    }
    
    return try block()
  }
}
