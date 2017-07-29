//
//  DataTypes.swift
//  Beacon
//
//  Created by Zhu Shengqi on 15/06/2017.
//  Copyright © 2017 zetasq. All rights reserved.
//

import Foundation
@testable import Beacon

class AccountManager {
  static let shared = AccountManager()
}

extension AccountManager: SignalBroadcasting {}

extension AccountManager {
  
  enum BroadcastIdentifier: String, BroadcastIdentifiable {
    
    case userLogin
    
    case userLogout
  }
}

extension AccountManager {
  
  struct BroadcastPayload {
    
    let username: String
    
    let time: Date
  }
}

class InterfaceController {
  
  init() {
    Beacon.default.addListener(self, broadcasterType: AccountManager.self, broadcastIdentifier: .userLogin) { [weak self] signal in
      self?.handleUserLogin(info: signal.payload)
    }
    
    Beacon.default.addListener(self, broadcasterType: AccountManager.self, broadcastIdentifier: .userLogout) { [weak self] signal in
      self?.handleUserLogout(info: signal.payload)
    }
  }
  
  func handleUserLogin(info: AccountManager.BroadcastPayload) {
    // do something when user login
  }
  
  func handleUserLogout(info: AccountManager.BroadcastPayload) {
    // do something when user logout
  }
  
  deinit {
    //print("\(self) deinit")
  }
}
