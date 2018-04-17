//
//  Beacon.swift
//  Beacon
//
//  Created by Zhu Shengqi on 14/06/2017.
//  Copyright © 2017 zetasq. All rights reserved.
//

import Foundation

public final class Beacon {
  
  public enum SignalObservingPolicy {
    case sync
    case async(queue: DispatchQueue)
  }
  
  public static let `default` = Beacon()
  
  // MARK: - Properties
  private var _lock = os_unfair_lock_s()
  
  /// structure: [broadcastID: [listener: SignalObserver]]
  private var _broadcastTable: [String: NSMapTable<AnyObject, AnyObject>] = [:]
  
  // MARK: - Init & Deinit
  public init() {}
  
  // MARK: - API Methods
  public func addListener<T: SignalBroadcasting>(_ listener: AnyObject, broadcasterType: T.Type, broadcastIdentifier: T.BroadcastIdentifier, broadcaster: T? = nil, observingPolicy: SignalObservingPolicy = .sync, signalHandler: @escaping SignalHandler<T>) {
    let uniqueBroadcastID = T.uniqueBroadcastID(for: broadcastIdentifier)
    
    os_unfair_lock_lock(&_lock)
    defer {
      os_unfair_lock_unlock(&_lock)
    }
    
    let signalObserver = SignalObserver(observingPolicy: observingPolicy, broadcaster: broadcaster, signalHandler: signalHandler)
    
    if let identifierTable = _broadcastTable[uniqueBroadcastID] {
      identifierTable.setObject(signalObserver, forKey: listener)
    } else {
      let identifierTable = NSMapTable<AnyObject, AnyObject>.weakToStrongObjects()
      _broadcastTable[uniqueBroadcastID] = identifierTable
      identifierTable.setObject(signalObserver, forKey: listener)
    }
  }
  
  public func removeListener(_ listener: AnyObject) {
    os_unfair_lock_lock(&_lock)
    defer {
      os_unfair_lock_unlock(&_lock)
    }
    
    for (_, identifierTable) in _broadcastTable {
      identifierTable.removeObject(forKey: listener)
    }
  }
  
  public func removeListener<T: SignalBroadcasting>(_ listener: AnyObject, broadcastingType: T.Type, identifier: T.BroadcastIdentifier) {
    let uniqueBroadcastID = T.uniqueBroadcastID(for: identifier)
    
    os_unfair_lock_lock(&_lock)
    defer {
      os_unfair_lock_unlock(&_lock)
    }
    
    if let identifierTable = _broadcastTable[uniqueBroadcastID] {
      identifierTable.removeObject(forKey: listener)
    }
  }
  
  public func removeListener<T: SignalBroadcasting>(_ listener: AnyObject, for broadcastIdentifier: T.BroadcastIdentifier? = nil, from broadcaster: T) {
    if let broadcastIdentifier = broadcastIdentifier {
      let uniqueBroadcastID = T.uniqueBroadcastID(for: broadcastIdentifier)
      
      os_unfair_lock_lock(&_lock)
      defer {
        os_unfair_lock_unlock(&_lock)
      }
      
      if let identifierTable = _broadcastTable[uniqueBroadcastID],
        let observer = identifierTable.object(forKey: listener) as? SignalObserver<T>,
        observer.broadcaster === broadcaster {
        identifierTable.removeObject(forKey: listener)
      }
    } else {
      os_unfair_lock_lock(&_lock)
      defer {
        os_unfair_lock_unlock(&_lock)
      }
      
      for (_, identifierTable) in _broadcastTable {
        if let observer = identifierTable.object(forKey: listener) as? SignalObserver<T>,
          observer.broadcaster === broadcaster {
          identifierTable.removeObject(forKey: listener)
        }
      }
    }
  }
  
  // MARK: - Internal Methods
  internal func enqueueBroadcastRequest<T: SignalBroadcasting>(broadcaster: T, identifier: T.BroadcastIdentifier, payload: T.BroadcastPayload) {
    let uniqueBroadcastID = T.uniqueBroadcastID(for: identifier)
    
    var interestedObservers: [SignalObserver<T>] = []
    
    os_unfair_lock_lock(&_lock)
    
    if let identifierTable = _broadcastTable[uniqueBroadcastID], let objectEnumerator = identifierTable.objectEnumerator() {
      for object in objectEnumerator {
        let observer = object as! SignalObserver<T>
        
        if observer.broadcaster == nil || observer.broadcaster === broadcaster {
          interestedObservers.append(observer)
        }
      }
    }
    
    os_unfair_lock_unlock(&_lock)
    
    for observer in interestedObservers {
      switch observer.observingPolicy {
      case .sync:
        let signal = Signal(sender: broadcaster, payload: payload)
        observer.signalHandler(signal)
      case .async(let queue):
        queue.async {
          let signal = Signal(sender: broadcaster, payload: payload)
          observer.signalHandler(signal)
        }
      }
    }
  }
}
