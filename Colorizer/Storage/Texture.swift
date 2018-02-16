// Copyright © 2018 Julian Dunskus. All rights reserved.

import Cocoa
import Bitmap

@objcMembers
class Texture: NSObject, Codable {
	dynamic var name: String
	dynamic var path: URL { // has to have "file://" prefix for NSImage to load it
		didSet {
			if path != oldValue {
				loadImage()
				if outputPath == oldValue.deletingLastPathComponent() {
					outputPath = path.deletingLastPathComponent()
				}
			}
		}
	}
	dynamic var outputPath: URL
	dynamic var image: NSImage!
	dynamic var levels: [CGFloat]!
	dynamic var mapDomainMin: CGFloat = 0.0
	dynamic var mapDomainMax: CGFloat = 1.0
	// TODO gradient map variable? (h/s/v)
	// TODO mask
	
	init(named name: String, at path: URL, outputtingTo outputPath: URL) {
		self.name = name
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
		image = NSImage(contentsOf: path)!
		assert(image.isValid)
		let cgImage = image.cgImage(forProposedRect: nil, context: nil, hints: [:])!
		let bitmap = Bitmap(from: cgImage)
		var histogram = [Int](repeating: 0, count: 256)
		for pixel in bitmap.pixels {
			histogram[Int(pixel.brightness)] += 1
		}
		let max = CGFloat(histogram.max()!)
		levels = histogram.map { CGFloat($0) / max }
	}
	
	func colorized(by colorization: Colorization) -> CGImage {
		let cgImage = image.cgImage(forProposedRect: nil, context: nil, hints: [:])!
		let bitmap = Bitmap(from: cgImage)
		let low = UInt8(mapDomainMin * 255)
		let dist = mapDomainMax - mapDomainMin
		for y in 0..<bitmap.height {
			for x in 0..<bitmap.width {
				let brightness = bitmap[x, y].brightness
				let clamped = max(low, brightness) - low
				let factor = min(1, CGFloat(clamped) / 255 / dist)
				let color = factor.interpolate(zero: colorization.low, one: colorization.high)
				bitmap[x, y] = Pixel(color)
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
		return NSColor(hue:        interpolate(zero: zero.hueComponent,        one: one.hueComponent),
					   saturation: interpolate(zero: zero.saturationComponent, one: one.saturationComponent),
					   brightness: interpolate(zero: zero.brightnessComponent, one: one.brightnessComponent),
					   alpha:      interpolate(zero: zero.alphaComponent,      one: one.alphaComponent))
	}
}
