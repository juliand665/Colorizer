//  Copyright © 2017 Julian Dunskus. All rights reserved.

import Cocoa

@objcMembers
class ColorSet: NSObject, Codable {
	dynamic var colorizations: [Colorization] = []
	dynamic var textures: [Texture] = []
	
	func reloadImages() {
		for texture in textures {
			texture.loadImage()
			texture.loadMask()
		}
	}
	
	func colorizeAll() {
		colorizations.forEach(colorizeAllTextures)
	}
	
	func colorizeUsingAll(_ texture: Texture) {
		for colorization in colorizations {
			colorize(texture, using: colorization)
		}
	}
	
	func colorizeAllTextures(using colorization: Colorization) {
		for texture in textures {
			colorize(texture, using: colorization)
		}
	}
	
	func colorize(_ texture: Texture, using colorization: Colorization) {
		let colorized = texture.colorized(by: colorization)
		let filename = texture.filename.replacingOccurrences(of: "%", with: colorization.filename)
		let path = texture.outputPath.appendingPathComponent("\(filename).png")
		let png = NSBitmapImageRep(cgImage: colorized).representation(using: .png, properties: [:])!
		try! png.write(to: path)
	}
}
