// Copyright © 2018 Julian Dunskus. All rights reserved.

import Cocoa

class ColorCellView: NSTableCellView, LoadedTableCell {
	static let reuseID = NSUserInterfaceItemIdentifier("Color Cell")
	
	@IBOutlet weak var colorView: ColorizationView!
	@IBOutlet weak var nameLabel: NSTextField!
	
	@IBAction func nameEdited(_ sender: NSTextField) {
		colorization.name = nameLabel.stringValue
	}
	
	var colorization: Colorization! {
		didSet {
			colorView.colorization = colorization
			colorization.observeChanges(as: self, runRightNow: true) { [weak self] in
				self?.update()
			}
		}
	}
	
	func update() { 
		nameLabel.stringValue = colorization.name
		colorView.setNeedsDisplay(colorView.bounds)
	}
}

class ColorizationView: NSView {
	var colorization: Colorization!
	
	override func draw(_ dirtyRect: NSRect) {
		let halfW = bounds.width / 2
		let halfH = bounds.height / 2
		let low = colorization.low.nsColor
		let high = colorization.high.nsColor
		NSColor.clear.setStroke()
		
		// Rectangles + Gradient
		high.setFill()
		NSRect(x: 0, y: halfH, width: halfW, height: halfH).fill()
		low.setFill()
		NSRect(x: 0, y: 0, width: halfW, height: halfH).fill()
		let gradient = NSGradient(starting: high, ending: low)!
		gradient.draw(in: NSRect(x: halfW, y: 0, width: halfW, height: bounds.height), angle: -90)
		
		/* Triangles:
		low.setFill()
		bounds.fill()
		high.setFill()
		let triangle = NSBezierPath()
		triangle.move(to: .zero)
		triangle.line(to: NSPoint(x: 0, y: bounds.height))
		triangle.line(to: NSPoint(x: bounds.width, y: bounds.height))
		triangle.close()
		triangle.fill()
		*/
	}
}
