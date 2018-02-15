// Copyright © 2018 Julian Dunskus. All rights reserved.

import Cocoa

class GradientView: NSView {
	var leftColor = #colorLiteral(red: 0, green: 0, blue: 0, alpha: 1) {
		didSet {
			setNeedsDisplay(bounds)
		}
	}
	var rightColor = #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1) {
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
