//  Copyright © 2017 Julian Dunskus. All rights reserved.

import Cocoa

class ColorSetDocument: NSDocument, Observable {
	var observers: [Observer: () -> Void] = [:]
	
	let encoder = JSONEncoder()
	let decoder = JSONDecoder()
	
	private(set) var colorSet = ColorSet() {
		didSet {
			observeColorSet()
		}
	}
	
	override class var autosavesInPlace: Bool {
		return false // TODO should this be true?
	}
	
	override init() {
		super.init()
		observeColorSet() // because didSet isn't called automatically
	}
	
	override func makeWindowControllers() {
		let storyboard = NSStoryboard(name: .init("Main"), bundle: nil)
		let controller = storyboard.instantiateController(withIdentifier: .init("Color Set Window Controller")) as! WindowController
		controller.contentViewController!.representedObject = self
		self.addWindowController(controller)
	}
	
	override func data(ofType typeName: String) throws -> Data {
		return try encoder.encode(colorSet)
	}
	
	override func read(from data: Data, ofType typeName: String) throws {
		colorSet = try decoder.decode(ColorSet.self, from: data)
	}
	
	func observeColorSet() {
		colorSet.observeChanges(as: self) { 
			self.updateChangeCount(.changeDone)
		}
	}
}
