// Copyright © 2018 Julian Dunskus. All rights reserved.

import Cocoa

class ColorizationCellView: NSTableCellView, LoadedTableCell {
	static let reuseID = NSUserInterfaceItemIdentifier("Color Cell")
	
	@IBOutlet weak var colorView: ColorizationView!
	@IBOutlet weak var nameLabel: NSTextField!
	
	var colorization: Colorization! {
		didSet {
			nameLabel.bind(.value, to: colorization, withKeyPath: #keyPath(Colorization.name))
			colorView.colorization = colorization
		}
	}
}

class ColorizationView: NSView {
	private var lowObservation: NSKeyValueObservation!
	private var highObservation: NSKeyValueObservation!
	
	var colorization: Colorization! {
		didSet {
			lowObservation = colorization.observe(\.low) { (_, _) in
				self.setNeedsDisplay(self.bounds)
			}
			highObservation = colorization.observe(\.high) { (_, _) in
				self.setNeedsDisplay(self.bounds)
			}
		}
	}
	
	override func draw(_ dirtyRect: NSRect) {
		let halfW = bounds.width / 2
		let halfH = bounds.height / 2
		let low = colorization.low
		let high = colorization.high
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
