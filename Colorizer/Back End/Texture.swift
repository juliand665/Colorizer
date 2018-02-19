// Copyright © 2018 Julian Dunskus. All rights reserved.

import Cocoa
import Bitmap

@objcMembers
class Texture: NSObject, Codable {
	dynamic var name: String
	dynamic var filename: String
	dynamic var path: URL {
		didSet {
			if path != oldValue {
				loadImage()
				if outputPath == oldValue.deletingLastPathComponent() {
					outputPath = path.deletingLastPathComponent()
				}
			}
		}
	}
	dynamic var image: NSImage!
	dynamic var outputPath: URL
	dynamic var maskPath: URL? {
		didSet {
			if path != oldValue {
				loadMask()
			}
		}
	}
	dynamic var maskImage: NSImage?
	dynamic var levels: [CGFloat]!
	dynamic var mapDomainMin: CGFloat = 0.0
	dynamic var mapDomainMax: CGFloat = 1.0
	
	init(named name: String, at path: URL, outputtingTo outputPath: URL) {
		self.name = name
		self.filename = name
		self.path = path
		self.outputPath = outputPath
		super.init()
		loadImage()
	}
	
	convenience init(named name: String, at path: URL) {
		self.init(named: name, at: path, outputtingTo: path.deletingLastPathComponent())
	}
	
	convenience init(at path: URL) {
		self.init(named: path.deletingPathExtension().lastPathComponent, at: path)
	}
	
	func loadImage() {
		// load image
		if let image = NSImage(contentsOf: path), image.isValid {
			self.image = image
		} else {
			self.image = #imageLiteral(resourceName: "MissingTexture")
		}
		// compute levels histogram
		let cgImage = image.cgImage()
		let bitmap = Bitmap(from: cgImage)
		let colors = bitmap.pixels.map { $0.nsColor }
		var histogram = [Int](repeating: 0, count: 256)
		for color in colors {
			histogram[Int(255 * color.brightnessComponent)] += 1
		}
		let maximum = CGFloat(histogram.max()!)
		levels = histogram.map { CGFloat($0) / maximum }
	}
	
	func loadMask() {
		if let path = maskPath,
			let mask = NSImage(contentsOf: path),
			mask.isValid,
			mask.size == image.size {
			maskImage = mask
		} else {
			maskImage = nil
		}
	}
	
	func colorized(by colorization: Colorization) -> CGImage {
		let cgImage = image.cgImage()
		let bitmap = Bitmap(from: cgImage)
		let mask = (maskImage?.cgImage()).map(Bitmap.init)
		let gradient = colorization.gradient
		let low = mapDomainMin
		let dist = max(0.0001, mapDomainMax - mapDomainMin) // avoid nonsense results
		for y in 0..<bitmap.height {
			for x in 0..<bitmap.width {
				let prev = bitmap[x, y].nsColor
				let clamped = max(0, prev.brightnessComponent - low)
				let factor = min(1, clamped / dist)
				var new = gradient.interpolatedColor(atLocation: factor)
				if let mask = mask {
					let opacity = CGFloat(mask[x, y].alpha) / 255
					new = opacity.interpolate(zero: prev, one: new)
				}
				bitmap[x, y] = Pixel(new.withAlphaComponent(prev.alphaComponent))
			}
		}
		return bitmap.cgImage()
	}
}

extension FloatingPoint {
	func interpolate(zero: Self, one: Self) -> Self {
		return zero + self * (one - zero)
	}
}

extension CGFloat {
	func interpolate(zero: NSColor, one: NSColor) -> NSColor {
		return NSColor(red:   interpolate(zero: zero.redComponent,   one: one.redComponent),
					   green: interpolate(zero: zero.greenComponent, one: one.greenComponent),
					   blue:  interpolate(zero: zero.blueComponent,  one: one.blueComponent),
					   alpha: interpolate(zero: zero.alphaComponent, one: one.alphaComponent))
	}
}

extension Pixel {
	var nsColor: NSColor {
		guard self.alpha > 0 else { return #colorLiteral(red: 1, green: 1, blue: 1, alpha: 0) }
		let alpha = CGFloat(self.alpha) // stupid premultiplication
		let color = NSColor(red:   CGFloat(red)   / alpha,
					   green: CGFloat(green) / alpha,
					   blue:  CGFloat(blue)  / alpha,
					   alpha: alpha / 255)
		return color
	}
}
