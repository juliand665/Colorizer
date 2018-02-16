//  Copyright © 2017 Julian Dunskus. All rights reserved.

import Cocoa

typealias DocumentPath<T> = ReferenceWritableKeyPath<ColorSetDocument, T>

class ColorSetDocument: NSDocument, Observable {
	var observations: [Address: AnyObservation] = [:]
	
	let encoder = JSONEncoder()
	let decoder = JSONDecoder()
	
	var colorSet = ColorSet()
	
	subscript<T>(_ keyPath: DocumentPath<T>) -> T {
		get {
			return self[keyPath: keyPath]
		}
		set {
			self[keyPath: keyPath] = newValue
		}
	}
	
	override class var autosavesInPlace: Bool {
		return false // TODO should this be true?
	}
	
	override init() {
		super.init()
	}
	
	override func makeWindowControllers() {
		let storyboard = NSStoryboard(name: .init("Main"), bundle: nil)
		let controller = storyboard.instantiateController(withIdentifier: .init("Color Set Window Controller")) as! WindowController
		self.addWindowController(controller)
	}
	
	override func data(ofType typeName: String) throws -> Data {
		return try encoder.encode(colorSet)
	}
	
	override func read(from data: Data, ofType typeName: String) throws {
		colorSet = try decoder.decode(ColorSet.self, from: data)
		updateChangeCount(.changeCleared)
	}
}
