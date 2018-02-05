//  Copyright © 2017 Julian Dunskus. All rights reserved.

import Cocoa

class ColorSet: Codable, Observable {
	var observers: [Observer: () -> Void] = [:]
	
	var colorizations: [Colorization] = [] {
		didSet {
			notifyObservers()
			colorizations.forEach { $0.observeChanges(as: self, calling: notifyObservers) }
		}
	}
	var textures: [Texture] = [] {
		didSet {
			notifyObservers()
			textures.forEach { $0.observeChanges(as: self, calling: notifyObservers) }
		}
	}
	
	init() {
		// TODO remove placeholders
		defer { // to call didSet
			colorizations = [
				Colorization(named: "test",
							 low: #colorLiteral(red: 0.9372549057, green: 0.3490196168, blue: 0.1921568662, alpha: 1).color,
							 high: #colorLiteral(red: 0.9764705896, green: 0.850980401, blue: 0.5490196347, alpha: 1).color)
			]
			textures = [
				Texture(named: "wool", at: URL(string: "file:///Users/juliandunskus/Documents/Active/Minecraft/Resources/Polishers/assets/minecraft/textures/blocks/wool_colored_white.png")!),
				Texture(named: "dickbutt", at: URL(string: "file:///Users/juliandunskus/Pictures/Funny:Cute:Interesting/dickbutt.png")!)
			]
		}
	}
	
	enum CodingKeys: CodingKey {
		case colorizations, textures
	}
}

class Texture: Codable, Observable {
	var observers: [Observer: () -> Void] = [:]
	
	var name: String { didSet { notifyObservers() } }
	var path: URL { didSet { notifyObservers() } } // has to have "file://" prefix for NSImage(byReferencing:) to work
	var outputPath: URL { didSet { notifyObservers() } }
	// TODO gradient map domain: values + type (h/s/v)
	// TODO only certain area
	
	init(named name: String, at path: URL, outputtingTo outputPath: URL) {
		self.name = name
		self.path = path
		self.outputPath = outputPath
	}
	
	convenience init(named name: String, at path: URL) {
		self.init(named: name, at: path, outputtingTo: path.deletingLastPathComponent())
	}
	
	convenience init(at path: URL) {
		self.init(named: path.deletingPathExtension().lastPathComponent, at: path)
	}
	
	var image: NSImage {
		let image = NSImage(byReferencing: path)
		assert(image.isValid)
		return image
	}
	
	func colorized(by colorization: Colorization) -> NSImage {
		// TODO
		return image
	}
	
	enum CodingKeys: CodingKey {
		case name, path, outputPath
	}
}

class Colorization: Codable, Observable {
	var observers: [Observer: () -> Void] = [:]
	
	var name: String     { didSet { notifyObservers() } }
	var filename: String { didSet { notifyObservers() } }
	var low: Color       { didSet { notifyObservers() } }
	var high: Color      { didSet { notifyObservers() } }
	
	init(named name: String, filename: String, low: Color, high: Color) {
		self.name = name
		self.filename = filename
		self.low = low
		self.high = high
	}
	
	convenience init(named name: String, low: Color, high: Color) {
		self.init(named: name, filename: "%_\(name)", low: low, high: high)
	}
	
	enum CodingKeys: CodingKey {
		case name, filename, low, high
	}
}

// because NSColor isn't codable >_>
struct Color: Codable {
	var hue: CGFloat
	var saturation: CGFloat
	var brightness: CGFloat
}

extension Color {
	var nsColor: NSColor {
		return NSColor(calibratedHue: hue,
					   saturation: saturation,
					   brightness: brightness,
					   alpha: 1)
	}
}

extension NSColor {
	var color: Color {
		return Color(hue: hueComponent,
					 saturation: saturationComponent,
					 brightness: brightnessComponent)
	}
}
