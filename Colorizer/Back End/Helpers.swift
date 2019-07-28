// Copyright © 2018 Julian Dunskus. All rights reserved.

import Cocoa

extension Array where Element: Equatable {
	mutating func remove(_ element: Element) {
		remove(at: firstIndex(of: element)!)
	}
}

extension NSImage {
	func cgImage() -> CGImage {
		return cgImage(forProposedRect: nil, context: nil, hints: nil)!
	}
}

extension CGImage {
	func nsImage() -> NSImage {
		return NSImage(cgImage: self, size: .zero)
	}
}

// MARK: -
// MARK: NSCoding → Codable

extension Decodable where Self: NSCoding {
	public init(from decoder: Decoder) throws {
		let container = try decoder.singleValueContainer()
		let data = try container.decode(Data.self)
		self = NSKeyedUnarchiver.unarchiveObject(with: data) as! Self
	}
}

extension Encodable where Self: NSCoding {
	public func encode(to encoder: Encoder) throws {
		let data = NSKeyedArchiver.archivedData(withRootObject: self)
		var container = encoder.singleValueContainer()
		try container.encode(data)
	}
}

extension NSImage: Codable {}
extension NSColor: Codable {}
