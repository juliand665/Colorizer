// Copyright © 2018 Julian Dunskus. All rights reserved.

import Foundation

/// `DispatchQueue` which discards all but the newest item when trying to execute them
class DiscardingQueue {
	var currentOperation = 0
	let underlyingQueue: DispatchQueue
	
	init(label: String) {
		underlyingQueue = DispatchQueue(label: label)
	}
	
	func async(execute block: @escaping () -> Void) {
		currentOperation += 1
		let op = currentOperation
		underlyingQueue.async {
			if self.currentOperation == op {
				block()
			}
		}
	}
}
