// Copyright © 2018 Julian Dunskus. All rights reserved.

import Cocoa

class TextureLevelsView: NSView {
	var texturePath: DocumentPath<Texture>! {
		didSet {
			setNeedsDisplay(bounds)
		}
	}
	
	override func draw(_ dirtyRect: NSRect) {
		super.draw(dirtyRect)
		
		guard let texture = document?[texturePath], let levels = texture.levels else { return }
		#colorLiteral(red: 0, green: 0, blue: 0, alpha: 1).set()
		let width = bounds.width / CGFloat(levels.count)
		var x: CGFloat = 0
		for value in levels {
			if x + width >= dirtyRect.minX, x <= dirtyRect.maxX {
				let height = bounds.height * value
				let rect = NSRect(x: x, y: 0, width: width, height: height)
				rect.fill()
				let edge = NSBezierPath(rect: rect)
				edge.lineWidth = 0.2
				edge.lineJoinStyle = .miterLineJoinStyle
				edge.stroke()
			}
			x += width
		}
	}
}
