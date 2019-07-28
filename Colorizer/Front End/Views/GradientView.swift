// Copyright © 2018 Julian Dunskus. All rights reserved.

import Cocoa

@objcMembers
class GradientView: NSView {
	dynamic var leftColor: NSColor! {
		didSet {
			setNeedsDisplay(bounds)
		}
	}
	dynamic var rightColor: NSColor! {
		didSet {
			setNeedsDisplay(bounds)
		}
	}
	
	override func draw(_ dirtyRect: NSRect) {
		let gradient = NSGradient(starting: leftColor, ending: rightColor)!
		gradient.draw(in: bounds, angle: 0)
		
		let edge = NSBezierPath()
		edge.appendRect(bounds)
		edge.lineCapStyle = .square
		edge.lineJoinStyle = .miter
		
		edge.lineWidth = 2
		NSColor.controlBackgroundColor.set() // next color is semi-transparent
		edge.stroke()
		NSColor.tertiaryLabelColor.set() // closest thing to what i'd like
		edge.stroke()
	}
}

extension NSBindingName {
	static let leftColor = NSBindingName("leftColor")
	static let rightColor = NSBindingName("rightColor")
}
