//
//  ColorSet.swift
//  Colorizer
//
//  Created by Julian Dunskus on 16.04.17.
//  Copyright © 2017 Julian Dunskus. All rights reserved.
//

import Foundation
import AppKit

class ColorSet: NSObject, NSCoding {
	
	var textures: [NSImage] = [NSImage(named: "dickbutt")!]
	var activeTextureIndex: Int?
	var colors: [NSColor] = []
	
	override init() {
		super.init()
	}
	
	required init?(coder: NSCoder) {
		guard
			let textures = coder.decodeObject(forKey: "textures") as? [NSImage],
			let colors = coder.decodeObject(forKey: "colors") as? [NSColor] else {
				return nil
		}
		self.textures = textures
		self.colors = colors
		
		self.activeTextureIndex = coder.decodeObject(forKey: "activeTextureIndex") as? Int
	}
	
	func encode(with coder: NSCoder) {
		coder.encode(textures, forKey: "textures")
		coder.encode(activeTextureIndex, forKey: "activeTextureIndex")
		coder.encode(colors, forKey: "colors")
	}
}
