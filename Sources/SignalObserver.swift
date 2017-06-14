//
//  SignalObserver.swift
//  Beacon
//
//  Created by Zhu Shengqi on 15/06/2017.
//  Copyright © 2017 zetasq. All rights reserved.
//

import Foundation

final class SignalObserver<T: SignalBroadcasting> {
  
  let observingPolicy: Beacon.SignalObservingPolicy
  
  private(set) weak var broadcaster: T?
  
  let signalHandler: SignalHandler<T>
  
  init(observingPolicy: Beacon.SignalObservingPolicy, broadcaster: T?, signalHandler: @escaping SignalHandler<T>) {
    self.observingPolicy = observingPolicy
    self.broadcaster = broadcaster
    self.signalHandler = signalHandler
  }
}
