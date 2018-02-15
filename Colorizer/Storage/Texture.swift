// Copyright © 2018 Julian Dunskus. All rights reserved.

import Cocoa
import Bitmap

struct Texture: Codable {
	var name: String
	var path: URL { // has to have "file://" prefix for NSImage to load it
		didSet {
			if path != oldValue {
				loadImage()
			}
		}
	}
	var outputPath: URL
	private var _image: NSContainer<NSImage>!
	var levels: [CGFloat]!
	var mapDomainMin: CGFloat = 0.0
	var mapDomainMax: CGFloat = 1.0
	// TODO gradient map variable? (h/s/v)
	// TODO only certain area
	
	var image: NSImage {
		get {
			return _image.contained
		}
		set {
			_image = NSContainer(for: newValue)
		}
	}
	
	init(named name: String, at path: URL, outputtingTo outputPath: URL) {
		self.name = name
		self.path = path
		self.outputPath = outputPath
		loadImage()
	}
	
	init(named name: String, at path: URL) {
		self.init(named: name, at: path, outputtingTo: path.deletingLastPathComponent())
	}
	
	init(at path: URL) {
		self.init(named: path.deletingPathExtension().lastPathComponent, at: path)
	}
	
	mutating func loadImage() {
		image = NSImage(contentsOf: path)!
		assert(image.isValid)
		let cgImage = image.cgImage(forProposedRect: nil, context: nil, hints: [:])!
		let bitmap = Bitmap(from: cgImage)
		var histogram = [Int](repeating: 0, count: 256)
		for pixel in bitmap.pixels {
			histogram[Int(pixel.brightness)] += 1
		}
		let max = CGFloat(histogram.max() ?? 1) // nothing matters anyway if it's empty
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
				bitmap[x, y] = color.pixel
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

extension Color {
	var pixel: Pixel {
		return Pixel(nsColor)
	}
}

extension FloatingPoint {
	func interpolate(zero: Self, one: Self) -> Self {
		return zero + self * (one - zero)
	}
}

extension CGFloat {
	func interpolate(zero: Color, one: Color) -> Color {
		return Color(hue: interpolate(zero: zero.hue, one: one.hue),
					 saturation: interpolate(zero: zero.saturation, one: one.saturation),
					 brightness: interpolate(zero: zero.brightness, one: one.brightness))
	}
}
