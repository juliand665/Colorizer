// Copyright © 2018 Julian Dunskus. All rights reserved.

import Cocoa

class TextureViewController: NSViewController, LoadedViewController {
	static var sceneID = NSStoryboard.SceneIdentifier("Texture")
	
	@IBOutlet weak var nameField: NSTextField!
	@IBOutlet weak var inputPathControl: NSPathControl!
	@IBOutlet weak var outputPathControl: NSPathControl!
	@IBOutlet weak var levelsView: TextureLevelsView!
	@IBOutlet weak var maxSlider: NSSlider!
	@IBOutlet weak var minSlider: NSSlider!
	
	var texture: Texture! {
		didSet {
			levelsView.texture = texture
			nameField.bind(.value, to: texture, withKeyPath: #keyPath(Texture.name))
			maxSlider.bind(.value, to: texture, withKeyPath: #keyPath(Texture.mapDomainMax))
			minSlider.bind(.value, to: texture, withKeyPath: #keyPath(Texture.mapDomainMin))
			inputPathControl.bind(.value, to: texture, withKeyPath: #keyPath(Texture.path))
			outputPathControl.bind(.value, to: texture, withKeyPath: #keyPath(Texture.outputPath))
		}
	}
}
