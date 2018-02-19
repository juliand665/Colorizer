// Copyright © 2018 Julian Dunskus. All rights reserved.

import Cocoa

class ColorizationViewController: NSViewController, LoadedViewController {
	static let sceneID = NSStoryboard.SceneIdentifier("Colorization")
	
	@IBOutlet weak var nameField: NSTextField!
	@IBOutlet weak var filenameField: NSTextField!
	@IBOutlet weak var lowColorWell: NSColorWell!
	@IBOutlet weak var highColorWell: NSColorWell!
	@IBOutlet weak var gradientView: GradientView!
	@IBOutlet weak var previewView: NSView!
	
	@IBAction func refreshPreview(_ sender: Any? = nil) {
		let textures = colorSet.textures
		let colorization = self.colorization!
		previewViewController.update {
			Array(textures
				.lazy // so we don't have to store quite as many intermediate CGImages
				.map { $0.colorized(by: colorization) }
				.map { NSImage(cgImage: $0, size: .zero) }
			)
		}
	}
	
	@IBAction func colorizeAndSave(_ sender: Any? = nil) {
		colorSet.colorizeAllTextures(using: colorization)
	}
	
	var previewViewController: PreviewViewController!
	var colorization: Colorization! {
		didSet {
			nameField.bind(.value, to: colorization, withKeyPath: #keyPath(Colorization.name))
			filenameField.bind(.value, to: colorization, withKeyPath: #keyPath(Colorization.filename))
			lowColorWell.bind(.value, to: colorization, withKeyPath: #keyPath(Colorization.low))
			highColorWell.bind(.value, to: colorization, withKeyPath: #keyPath(Colorization.high))
			gradientView.bind(.leftColor, to: colorization, withKeyPath: #keyPath(Colorization.low))
			gradientView.bind(.rightColor, to: colorization, withKeyPath: #keyPath(Colorization.high))
			previewViewController.prepare()
			refreshPreview()
		}
	}
	
	override func viewDidLoad() {
		super.viewDidLoad()
		previewViewController = storyboard!.instantiate(PreviewViewController.self)
		addChildViewController(previewViewController)
		previewView.addSubview(previewViewController.view)
		previewViewController.view.frame = previewView.bounds
		previewViewController.view.autoresizingMask = [.width, .height]
	}
}
