// Copyright © 2018 Julian Dunskus. All rights reserved.

import Foundation

func address(of object: AnyObject) -> Int {
	return unsafeBitCast(object, to: Int.self)
}

// assign if changed (so as not to trigger didSet unnecessarily)
infix operator ∂=: AssignmentPrecedence
func ∂= <T>(lhs: inout T, rhs: T) where T: Equatable {
	if lhs != rhs {
		lhs = rhs
	}
}

// encode/decode NSCoding objects
struct NSContainer<Contained: NSCoding>: Codable {
	let contained: Contained
	
	init(for contained: Contained) {
		self.contained = contained
	}
	
	init(from decoder: Decoder) throws {
		let container = try decoder.singleValueContainer()
		let data = try container.decode(Data.self)
		contained = NSKeyedUnarchiver.unarchiveObject(with: data) as! Contained
	}
	
	func encode(to encoder: Encoder) throws {
		let data = NSKeyedArchiver.archivedData(withRootObject: contained)
		var container = encoder.singleValueContainer()
		try container.encode(data)
	}
}
