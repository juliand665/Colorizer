// Copyright © 2018 Julian Dunskus. All rights reserved.

import Cocoa

class ColorizationViewController: NSViewController, LoadedViewController {
	static let sceneID = "Colorization"
	
	@IBOutlet var nameField: NSTextField!
	@IBOutlet var filenameField: NSTextField!
	@IBOutlet var lowColorWell: NSColorWell!
	@IBOutlet var highColorWell: NSColorWell!
	@IBOutlet var gradientView: GradientView!
	@IBOutlet var previewView: NSView!
	
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
	
	var lowObservation: NSKeyValueObservation!
	var highObservation: NSKeyValueObservation!
	
	var previewViewController: PreviewViewController!
	var colorization: Colorization! {
		didSet {
			nameField.bind(.value, to: colorization!, withKeyPath: #keyPath(Colorization.name))
			filenameField.bind(.value, to: colorization!, withKeyPath: #keyPath(Colorization.filename))
			lowColorWell.bind(.value, to: colorization!, withKeyPath: #keyPath(Colorization.low))
			highColorWell.bind(.value, to: colorization!, withKeyPath: #keyPath(Colorization.high))
			gradientView.bind(.leftColor, to: colorization!, withKeyPath: #keyPath(Colorization.low))
			gradientView.bind(.rightColor, to: colorization!, withKeyPath: #keyPath(Colorization.high))
			lowObservation = colorization.observe(\.low) { [unowned self] (_, _) in
				self.refreshPreview()
			}
			highObservation = colorization.observe(\.high) { [unowned self] (_, _) in
				self.refreshPreview()
			}
			previewViewController.prepare()
			refreshPreview()
		}
	}
	
	override func viewDidLoad() {
		super.viewDidLoad()
		previewViewController = storyboard!.instantiate(PreviewViewController.self)
		addChild(previewViewController)
		previewView.addSubview(previewViewController.view)
		previewViewController.view.frame = previewView.bounds
		previewViewController.view.autoresizingMask = [.width, .height]
	}
}
