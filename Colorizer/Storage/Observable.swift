// Copyright © 2018 Julian Dunskus. All rights reserved.

import Foundation

typealias Observer = Int

protocol Observable: class {
	var observers: [Observer: () -> Void] { get set }
	
	func observeChanges(as object: AnyObject, runRightNow: Bool, calling handler: @escaping () -> Void)
	func stopObserving(as object: AnyObject)
	func notifyObservers()
}

extension Observable {
	func observeChanges(as object: AnyObject, runRightNow: Bool = false, calling handler: @escaping () -> Void) {
		let key = unsafeBitCast(object, to: Int.self) // use address of object to access memory
		if runRightNow, observers[key] == nil {
			handler()
		}
		observers[key] = handler
	}
	
	func stopObserving(as object: AnyObject) {
		let key = unsafeBitCast(object, to: Int.self)
		observers[key] = nil
	}
	
	func notifyObservers() {
		observers.values.forEach { $0() }
	}
}
