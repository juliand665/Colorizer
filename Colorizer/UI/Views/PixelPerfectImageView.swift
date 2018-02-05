//  Copyright © 2017 Julian Dunskus. All rights reserved.

import AppKit

/// Scales down with anti-aliasing, up with aliasing
@IBDesignable
class PixelPerfectImageView: NSImageView {
    
    override func draw(_ dirtyRect: NSRect) {
        let prev = NSGraphicsContext.current!.imageInterpolation
        if let img = image, img.size < frame.size {
            NSGraphicsContext.current!.imageInterpolation = .none
        }
        super.draw(dirtyRect)
        NSGraphicsContext.current!.imageInterpolation = prev
    }
}
