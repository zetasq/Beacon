//
//  SignalBroadcasting.swift
//  Beacon
//
//  Created by Zhu Shengqi on 14/06/2017.
//  Copyright © 2017 zetasq. All rights reserved.
//

import Foundation

public protocol BroadcastIdentifiable: RawRepresentable {
  
  var rawValue: String { get }
  
}

public protocol SignalBroadcasting: class {
  
  associatedtype BroadcastIdentifier: BroadcastIdentifiable
  
  associatedtype BroadcastPayload
  
}

extension SignalBroadcasting {
  
  public func broadcast(identifier: BroadcastIdentifier, payload: BroadcastPayload, within beacon: Beacon = .default) {
    beacon.enqueueBroadcastRequest(broadcaster: self, identifier: identifier, payload: payload)
  }
  
  public static func uniqueBroadcastID(for broadcastIdentifier: BroadcastIdentifier) -> String {
    let qualifiedName = String(reflecting: self)
    return "\(qualifiedName).\(broadcastIdentifier.rawValue)"
  }
  
}
