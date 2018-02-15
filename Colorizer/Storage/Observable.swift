// Copyright © 2018 Julian Dunskus. All rights reserved.

import Foundation

typealias Address = Int

protocol Observable: class {
	var observations: [Address: AnyObservation] { get set }
	
	func observeChanges<T>(as observer: T, runRightNow: Bool, calling callback: @escaping (T) -> Void) where T: AnyObject
	func stopObserving<T>(as observer: T) where T: AnyObject
	func notifyObservers()
}

extension Observable {
	func observeChanges<T>(as observer: T, runRightNow: Bool = false, calling callback: @escaping (T) -> Void) where T: AnyObject {
		let key = address(of: observer)
		if runRightNow {
			callback(observer)
		}
		observations[key] = Observation(observer: observer, callback: callback)
	}
	
	func stopObserving<T>(as object: T) where T: AnyObject {
		let key = address(of: object)
		print(key)
		observations[key] = nil
	}
	
	func notifyObservers() {
		for (address, observation) in observations {
			if !observation.run() {
				observations[address] = nil
			}
		}
	}
}

protocol AnyObservation {
	func run() -> Bool
}

fileprivate class Observation<T>: AnyObservation where T: AnyObject {
	weak var observer: T?
	let callback: (T) -> Void
	
	init(observer: T, callback: @escaping (T) -> Void) {
		self.observer = observer
		self.callback = callback
	}
	
	func run() -> Bool {
		if let observer = observer {
			callback(observer)
			return true
		} else {
			return false
		}
	}
}
