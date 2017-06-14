//
//  Thread+Sync.swift
//  Beacon
//
//  Created by Zhu Shengqi on 15/06/2017.
//  Copyright © 2017 zetasq. All rights reserved.
//

import Foundation

func synchronized<T>(_ lock: AnyObject, _ body: () throws -> T) rethrows -> T {
  objc_sync_enter(lock)
  
  defer {
    objc_sync_exit(lock)
  }
  
  return try body()
}

func abc<T: SignalBroadcasting>(value: T.BroadcastIdentifier) {
  
}
