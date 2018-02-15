// Copyright © 2018 Julian Dunskus. All rights reserved.

import Cocoa

struct Colorization: Codable {
	var name: String
	var filename: String
	var low: Color
	var high: Color
	
	init(named name: String, filename: String, low: Color, high: Color) {
		self.name = name
		self.filename = filename
		self.low = low
		self.high = high
	}
	
	init(named name: String, low: Color, high: Color) {
		self.init(named: name, filename: "%_\(name)", low: low, high: high)
	}
}

// because NSColor isn't codable >_>
struct Color: Codable, Equatable {
	var hue: CGFloat
	var saturation: CGFloat
	var brightness: CGFloat
	
	static func ==(lhs: Color, rhs: Color) -> Bool {
		return lhs.hue == rhs.hue
			&& lhs.saturation == rhs.saturation
			&& lhs.brightness == rhs.brightness
	}
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
