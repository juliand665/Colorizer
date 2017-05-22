//
//  ColorSetDocument.swift
//  Colorizer
//
//  Created by Julian Dunskus on 14.04.17.
//  Copyright © 2017 Julian Dunskus. All rights reserved.
//

import Cocoa

class ColorSetDocument: NSDocument {
	
	var colorSet = ColorSet()
	
	override init() {
		super.init()
		
	}
	
	override class func autosavesInPlace() -> Bool {
		return true
	}
	
	override func makeWindowControllers() {
		let storyboard = NSStoryboard(name: "Main", bundle: nil)
		let windowController = storyboard.instantiateController(withIdentifier: "Color Set Window Controller") as! NSWindowController
		windowController.contentViewController!.representedObject = self
		self.addWindowController(windowController)
	}
	
	override func data(ofType typeName: String) throws -> Data {
		return NSKeyedArchiver.archivedData(withRootObject: colorSet)
	}
	
	override func read(from data: Data, ofType typeName: String) throws {
		if let colorSet = NSKeyedUnarchiver.unarchiveObject(with: data) as? ColorSet {
			self.colorSet = colorSet
		} else {
			throw error(description: "Invalid format! No Color Set could be read.")
		}
	}
}
