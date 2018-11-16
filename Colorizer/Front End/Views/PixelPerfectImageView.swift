//  Copyright © 2017 Julian Dunskus. All rights reserved.

import AppKit

/// Scales down with anti-aliasing, up without
@IBDesignable
class PixelPerfectImageView: NSImageView {
	override func draw(_ dirtyRect: NSRect) {
		let context = NSGraphicsContext.current!
		let prev = context.imageInterpolation
		let scale = window?.backingScaleFactor ?? 1
		if let image = image, image.size.width < scale * frame.size.width {
			context.imageInterpolation = .none
		}
		super.draw(dirtyRect)
		context.imageInterpolation = prev
	}
}
