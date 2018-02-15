// Copyright © 2018 Julian Dunskus. All rights reserved.

import Cocoa

class TextureViewController: NSViewController, LoadedViewController, DocumentObserving {
	static var sceneID = NSStoryboard.SceneIdentifier("Texture")
	
	@IBOutlet weak var nameField: NSTextField!
	@IBOutlet weak var inputPathControl: NSPathControl!
	@IBOutlet weak var outputPathControl: NSPathControl!
	@IBOutlet weak var levelsView: TextureLevelsView!
	@IBOutlet weak var maxSlider: NSSlider!
	@IBOutlet weak var minSlider: NSSlider!
	
	@IBAction func nameChanged(_ sender: NSTextField) {
		texture.name ∂= nameField.stringValue
	}
	
	@IBAction func inputPathChanged(_ sender: NSPathControl) {
		if let path = inputPathControl.url {
			// TODO validate
			texture.path ∂= path
			levelsView.setNeedsDisplay(levelsView.bounds)
		} else {
			inputPathControl.url = texture.path
		}
	}
	
	@IBAction func outputPathChanged(_ sender: NSPathControl) {
		if let path = outputPathControl.url {
			// TODO validate?
			texture.outputPath ∂= path
		} else {
			outputPathControl.url = texture.outputPath
		}
	}
	
	@IBAction func mapDomainChanged(_ sender: NSSlider) {
		texture.mapDomainMax = CGFloat(maxSlider.doubleValue)
		texture.mapDomainMin = CGFloat(minSlider.doubleValue)
	}
	
	var texturePath: DocumentPath<Texture>!
	var texture: Texture {
		get {
			return document![texturePath]
		}
		set {
			document![texturePath] = newValue
		}
	}
	
	override func viewWillAppear() {
		super.viewWillAppear()
		levelsView.texturePath = texturePath
	}
	
	override func viewDidAppear() {
		super.viewDidAppear()
		maxSlider.doubleValue = Double(texture.mapDomainMax)
		minSlider.doubleValue = Double(texture.mapDomainMin)
		inputPathControl.url = texture.path
		outputPathControl.url = texture.outputPath
		
		startObserving()
	}
	
	func update() {
		nameField.stringValue = texture.name // can be changed from sidebar
	}
}
