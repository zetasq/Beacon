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
  
  /// structure: [broadcastID: [listener: [observer]]]
  private var _broadcastTable: [String: NSMapTable<AnyObject, NSMutableArray>] = [:]
  
  // MARK: - Init & Deinit
  public init() {}
  
  // MARK: - API Methods
  public func addListener<T: SignalBroadcasting>(_ listener: AnyObject, broadcasterType: T.Type, broadcastIdentifier: T.BroadcastIdentifier, broadcaster: T? = nil, observingPolicy: SignalObservingPolicy = .sync, signalHandler: @escaping SignalHandler<T>) {
    let uniqueBroadcastID = T.uniqueBroadcastID(for: broadcastIdentifier)
    
    synchronized(self) {
      let signalObserver = SignalObserver(observingPolicy: observingPolicy, broadcaster: broadcaster, signalHandler: signalHandler)

      if let identifierTable = _broadcastTable[uniqueBroadcastID] {
        if let observerArray = identifierTable.object(forKey: listener) {
          observerArray.add(signalObserver)
        } else {
          let observerArray = NSMutableArray(object: signalObserver)
          identifierTable.setObject(observerArray, forKey: listener)
        }
      } else {
        let identifierTable = NSMapTable<AnyObject, NSMutableArray>(keyOptions: [.weakMemory, .objectPersonality], valueOptions: [.strongMemory, .objectPersonality])
        _broadcastTable[uniqueBroadcastID] = identifierTable
        
        let observerArray = NSMutableArray(object: signalObserver)
        identifierTable.setObject(observerArray, forKey: listener)
      }
    }
  }
  
  public func removeListener(_ listener: AnyObject) {
    synchronized(self) {
      for (_, identifierTable) in _broadcastTable {
        identifierTable.removeObject(forKey: listener)
      }
    }
  }
  
  public func removeListener<T: SignalBroadcasting>(_ listener: AnyObject, for broadcastIdentifier: T.BroadcastIdentifier) {
    let uniqueBroadcastID = T.uniqueBroadcastID(for: broadcastIdentifier)
    
    synchronized(self) {
      if let identifierTable = _broadcastTable[uniqueBroadcastID] {
        identifierTable.removeObject(forKey: listener)
      }
    }
  }
  
  public func removeListener<T: SignalBroadcasting>(_ listener: AnyObject, for broadcastIdentifier: T.BroadcastIdentifier? = nil, from broadcaster: T) {
    if let broadcastIdentifier = broadcastIdentifier {
      let uniqueBroadcastID = T.uniqueBroadcastID(for: broadcastIdentifier)
      
      synchronized(self) {
        if let identifierTable = _broadcastTable[uniqueBroadcastID], let observerArray = identifierTable.object(forKey: listener) {
          let observers = observerArray as! [SignalObserver<T>]
          
          for (index, observer) in observers.enumerated() where observer.broadcaster === broadcaster {
            observerArray.removeObject(at: index)
          }
        }
      }
    } else {
      synchronized(self) {
        for (_, identifierTable) in _broadcastTable {
          if let observerArray = identifierTable.object(forKey: listener) {
            let observers = observerArray as! [SignalObserver<T>]
            
            for (index, observer) in observers.enumerated() where observer.broadcaster === broadcaster {
              observerArray.removeObject(at: index)
            }
          }
        }
      }
    }
  }
  
  // MARK: - Internal Methods
  internal func enqueueBroadcastRequest<T: SignalBroadcasting>(broadcaster: T, identifier: T.BroadcastIdentifier, payload: T.BroadcastPayload) {
    let uniqueBroadcastID = T.uniqueBroadcastID(for: identifier)
    
    synchronized(self) {
      guard let identifierTable = _broadcastTable[uniqueBroadcastID], let objectEnumerator = identifierTable.objectEnumerator() else {
        return
      }
      
      for observerArray in objectEnumerator {
        let observers = observerArray as! [SignalObserver<T>]
        
        for observer in observers {
          if observer.broadcaster == nil || observer.broadcaster! === broadcaster {
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
    }
  }
}
