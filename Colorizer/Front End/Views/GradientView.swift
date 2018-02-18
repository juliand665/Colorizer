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
		edge.move(to: .zero)
		edge.line(to: NSPoint(x: 0, y: bounds.height))
		edge.line(to: NSPoint(x: bounds.width, y: bounds.height))
		edge.line(to: NSPoint(x: bounds.width, y: 0))
		edge.close()
		edge.lineCapStyle = .squareLineCapStyle
		edge.lineJoinStyle = .miterLineJoinStyle
		
		edge.lineWidth = 12
		#colorLiteral(red: 0.5411764706, green: 0.5411764706, blue: 0.5411764706, alpha: 1).setStroke()
		edge.stroke()
		
		edge.lineWidth = 10
		#colorLiteral(red: 0.937254902, green: 0.937254902, blue: 0.937254902, alpha: 1).setStroke()
		edge.stroke()
		
		edge.lineWidth = 2
		#colorLiteral(red: 0.6862745098, green: 0.6862745098, blue: 0.6862745098, alpha: 1).setStroke()
		edge.stroke()
	}
}

extension NSBindingName {
	static let leftColor = NSBindingName("leftColor")
	static let rightColor = NSBindingName("rightColor")
}
