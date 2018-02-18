// Copyright © 2018 Julian Dunskus. All rights reserved.

import Cocoa

extension Array where Element: Equatable {
	mutating func remove(_ element: Element) {
		remove(at: index(of: element)!)
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

// MARK: -
// MARK: Decoding Helpers

precedencegroup AccessPrecedence {
	higherThan: BitwiseShiftPrecedence
	associativity: left
}

infix operator →  : AccessPrecedence
infix operator →? : AccessPrecedence
infix operator →! : AccessPrecedence

extension KeyedDecodingContainer {
	/// decode if present
	static func → <T: Decodable>(container: KeyedDecodingContainer, key: Key) throws -> T? {
		return try container.decodeIfPresent(T.self, forKey: key)
	}
	
	/// decode if present, returning nil upon error
	static func →? <T: Decodable>(container: KeyedDecodingContainer, key: Key) -> T? {
		return (try? container.decodeIfPresent(T.self, forKey: key)) ?? nil // doubly wrapped → singly wrapped
	}
	
	/// decode if present, throwing an error if not present
	static func →! <T: Decodable>(container: KeyedDecodingContainer, key: Key) throws -> T {
		// This is not the same as `decode`, because it doesn't insert a stupid placeholder if the key is not present.
		if let result = try container.decodeIfPresent(T.self, forKey: key) {
			return result
		} else {
			throw DecodingError.valueNotFound(T.self, .init(codingPath: container.codingPath, debugDescription: "Expected value for key \(key)!"))
		}
	}
}
