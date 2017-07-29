//
//  Signal.swift
//  Beacon
//
//  Created by Zhu Shengqi on 15/06/2017.
//  Copyright © 2017 zetasq. All rights reserved.
//

import Foundation

public typealias SignalHandler<T: SignalBroadcasting> = (Signal<T>) -> Void

public struct Signal<T: SignalBroadcasting> {
  
  public let sender: T
  
  public let payload: T.BroadcastPayload
  
}

