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
		var histogram = [Int](repeating: 0, count: 256)
		for pixel in bitmap.pixels {
			histogram[Int(pixel.brightness)] += 1
		}
		let max = CGFloat(histogram.max()!)
		levels = histogram.map { CGFloat($0) / max }
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
		let low = UInt8(mapDomainMin * 255)
		let dist = mapDomainMax - mapDomainMin
		for y in 0..<bitmap.height {
			for x in 0..<bitmap.width {
				let brightness = bitmap[x, y].brightness
				let clamped = max(low, brightness) - low
				let factor = min(1, CGFloat(clamped) / 255 / dist)
				let new = gradient.interpolatedColor(atLocation: factor)
				if let mask = mask {
					let opacity = CGFloat(mask[x, y].alpha) / 255
					let prev = bitmap[x, y].nsColor
					let mix = opacity.interpolate(zero: prev, one: new)
					bitmap[x, y] = Pixel(mix.withAlphaComponent(prev.alphaComponent))
				} else {
					let alpha = CGFloat(bitmap[x, y].alpha) / 255
					bitmap[x, y] = Pixel(new.withAlphaComponent(alpha))
				}
			}
		}
		return bitmap.cgImage()
	}
}

extension Pixel {
	var brightness: UInt8 {
		return max(max(red, green), blue)
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
		return NSColor(red:   CGFloat(red)   / 255,
					   green: CGFloat(green) / 255,
					   blue:  CGFloat(blue)  / 255,
					   alpha: CGFloat(alpha) / 255)
	}
}
