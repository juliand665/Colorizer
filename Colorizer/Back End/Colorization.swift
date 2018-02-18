// Copyright © 2018 Julian Dunskus. All rights reserved.

import Cocoa

@objcMembers
class Colorization: NSObject, Codable {
	dynamic var name: String {
		didSet {
			if filename.contains(oldValue) {
				filename = filename.replacingOccurrences(of: oldValue, with: name)
			}
		}
	}
	dynamic var filename: String
	dynamic var low: NSColor
	dynamic var high: NSColor
	
	var gradient: NSGradient {
		return NSGradient(starting: low, ending: high)!
	}
	
	init(named name: String, filename: String, low: NSColor, high: NSColor) {
		self.name = name
		self.filename = filename
		self.low = low
		self.high = high
		super.init()
	}
	
	convenience init(named name: String, low: NSColor, high: NSColor) {
		self.init(named: name, filename: "%_\(name.lowercased())", low: low, high: high)
	}
}
