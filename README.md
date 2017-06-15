# Beacon

A type-safe broadcasting framework to replace `NSNotificationCenter`

[![Carthage Compatible](https://img.shields.io/badge/Carthage-compatible-4BC51D.svg?style=flat)](https://github.com/Carthage/Carthage)

## Installation
### Carthage

[Carthage](https://github.com/Carthage/Carthage) is a decentralized dependency manager that builds your dependencies and provides you with binary frameworks.

You can install Carthage with [Homebrew](http://brew.sh/) using the following command:

```bash
$ brew update
$ brew install carthage
```

To integrate Beacon into your Xcode project using Carthage, specify it in your `Cartfile`:

```ogdl
github "zetasq/Beacon"
```

Run `carthage update` to build the framework and drag the built `Beacon.framework` into your Xcode project.

## Usage

In Beacon, there are two kinds of roles: `broadcaster` and `listener`. Broadcasters send their signals to interested listeners.

### Define a broadcaster

It's easy to make your existing class a broadcaster by conforming to `SignalBroadcasting`. You only need to declare two subtypes: `BroadcastIdentifier` and `BroadcastPayload`.

#### BroadcastIdentifier
This is like `Notification.Name` in the system `Foundation` framework. It needs to be `RawRepresentable` and has `rawValue` of type `String`. The easiest way is to use an `enum` whose `rawValue` is `String`.
> You don't have to make the `rawValue` strings unique across your app or in other frameworks. Beacon will concatenate the bundle name, the broadcaster class name and the `rawValue` string to make an unique identifier.
```swift
// You have AccountManager to handle account related logic
extension AccountManager {
  
  enum BroadcastIdentifier: String, BroadcastIdentifiable {
    
    case userLogin
    
    case userLogout
  }
}
```

#### BroadcastPayload
This is like the `userInfo` dictionary in `Notification` in the system `Foundation` framework, but `BroadcastPayload` is a concrete data type. You can use any data structure(struct, class, enum...) or make a typealias to an existing subtype.
```swift
extension AccountManager {
  
  struct BroadcastPayload {
    
    let username: String
    
    let time: Date
  }
}
```

> Don't forget add the `SignalBroadcasting` conformance: `extension AccountManager: SignalBroadcasting {}`

### Broadcast signals
After you define the broadcasters, you can use them to broadcast signals.
```swift
let accountManager = AccountManager.shared

accountManager.broadcast(identifier: .userLogin, payload: .init(username: "Mr. Anderson", time: Date()))
accountManager.broadcast(identifier: .userLogout, payload: .init(username: "Mr. Smith", time: Date()))
```

### Listen to broadcasting
As a listener, you want to listen to certain kinds of broadcasting(and maybe from a certain broadcaster!). 
```swift
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
}
```
> **IMPORTANT:** If you want to reference the listener(directly or indirectly), make sure you have added necessary `weak` references in the signal callback closures. Otherwise the listeners will never be released!
