//
//  SignalTests.swift
//  Beacon
//
//  Created by Zhu Shengqi on 15/06/2017.
//  Copyright © 2017 zetasq. All rights reserved.
//

import XCTest

@testable import Beacon

class SignalTests: XCTestCase {
  
  override func setUp() {
    super.setUp()
    // Put setup code here. This method is called before the invocation of each test method in the class.
  }
  
  override func tearDown() {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    super.tearDown()
  }
  
  func testExample() {
    // This is an example of a functional test case.
    // Use XCTAssert and related functions to verify your tests produce the correct results.
  }
  
  func testPerformanceExample() {
    // This is an example of a performance test case.
    self.measure {
      // Put the code you want to measure the time of here.
    }
  }
  
  func testReceivingSignals() {
    var userLoginSignalReceived = false
    var userLogoutSignalReceived = false
    
    let accountManager = AccountManager.shared
    let controller = InterfaceController()
    
    Beacon.default.addListener(controller, broadcasterType: AccountManager.self, broadcastIdentifier: .userLogin) { signal in
      userLoginSignalReceived = true
      XCTAssert(signal.payload.username == "Mr. Anderson", "userLogin payload not correct")
    }
    
    Beacon.default.addListener(controller, broadcasterType: AccountManager.self, broadcastIdentifier: .userLogout) { signal in
      userLogoutSignalReceived = true
      XCTAssert(signal.payload.username == "Mr. Smith", "userLogout payload not correct")
    }
    
    accountManager.broadcast(identifier: .userLogin, payload: .init(username: "Mr. Anderson", time: Date()))
    accountManager.broadcast(identifier: .userLogout, payload: .init(username: "Mr. Smith", time: Date()))
    
    XCTAssert(userLoginSignalReceived, "userLogin signal not received")
    XCTAssert(userLogoutSignalReceived, "userLogout signal not received")
  }
}
