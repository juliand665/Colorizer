//  Copyright © 2017 Julian Dunskus. All rights reserved.

import Cocoa

@objcMembers
class ColorSet: NSObject, Codable {
	dynamic var colorizations: [Colorization] = []
	dynamic var textures: [Texture] = []
	
	override init() {
		// TODO remove placeholders
		colorizations = [
			Colorization(named: "test",
						 low: #colorLiteral(red: 0.3647058904, green: 0.06666667014, blue: 0.9686274529, alpha: 1),
						 high: #colorLiteral(red: 0.2392156869, green: 0.6745098233, blue: 0.9686274529, alpha: 1))
		]
		textures = [
			Texture(named: "wool", at: URL(string: "file:///Users/juliandunskus/Documents/Active/Minecraft/Resources/Polishers/assets/minecraft/textures/blocks/wool_colored_white.png")!),
			Texture(named: "dickbutt", at: URL(string: "file:///Users/juliandunskus/Pictures/Funny:Cute:Interesting/dickbutt.png")!)
		]
		super.init()
	}
	
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
		let filename = colorization.filename.replacingOccurrences(of: "%", with: texture.filename)
		let path = texture.outputPath.appendingPathComponent("\(filename).png")
		let png = NSBitmapImageRep(cgImage: colorized).representation(using: .png, properties: [:])!
		try! png.write(to: path)
	}
}
