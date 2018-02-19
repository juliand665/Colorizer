// Copyright © 2018 Julian Dunskus. All rights reserved.

import Cocoa

class TextureViewController: NSViewController, LoadedViewController {
	static var sceneID = NSStoryboard.SceneIdentifier("Texture")
	
	@IBOutlet weak var nameField: NSTextField!
	@IBOutlet weak var filenameField: NSTextField!
	@IBOutlet weak var inputPathControl: NSPathControl!
	@IBOutlet weak var outputPathControl: NSPathControl!
	@IBOutlet weak var maskPathControl: NSPathControl!
	@IBOutlet weak var removeMaskButton: NSButton!
	@IBOutlet weak var levelsView: TextureLevelsView!
	@IBOutlet weak var maxSlider: NSSlider!
	@IBOutlet weak var minSlider: NSSlider!
	@IBOutlet weak var previewView: NSView!
	
	@IBAction func refreshPreview(_ sender: Any? = nil) {
		let colorizations = colorSet.colorizations
		let texture = self.texture!
		previewViewController.update {
			Array(colorizations
				.lazy // so we don't have to store quite as many intermediate CGImages
				.map(texture.colorized)
				.map { NSImage(cgImage: $0, size: .zero) }
			)
		}
	}
	
	@IBAction func removeMask(_ sender: Any) {
		texture.maskPath = nil
	}
	
	@IBAction func showFilenameHelp(_ sender: NSButton) {
		if filenameHelpPopover.isShown {
			filenameHelpPopover.close()
		} else {
			filenameHelpPopover.show(relativeTo: .zero, of: sender, preferredEdge: .minY)
		}
	}
	
	@IBAction func showMaskHelp(_ sender: NSButton) {
		if maskHelpPopover.isShown {
			maskHelpPopover.close()
		} else {
			maskHelpPopover.show(relativeTo: .zero, of: sender, preferredEdge: .minY)
		}
	}
	
	@IBAction func colorizeAndSave(_ sender: Any? = nil) {
		colorSet.colorizeUsingAll(texture)
	}
	
	@IBAction func reloadTexture(_ sender: Any? = nil) {
		texture.loadImage()
		texture.loadMask()
	}
	
	var previewViewController: PreviewViewController!
	
	var imageObservation: NSKeyValueObservation!
	var maskPathObservation: NSKeyValueObservation!
	var maskObservation: NSKeyValueObservation!
	
	lazy var filenameHelpPopover: NSPopover = {
		let popover = NSPopover()
		popover.contentViewController = storyboard!.instantiate(FilenameHelpViewController.self)
		popover.behavior = .semitransient
		return popover
	}()
	lazy var maskHelpPopover: NSPopover = {
		let popover = NSPopover()
		popover.contentViewController = storyboard!.instantiate(MaskHelpViewController.self)
		popover.behavior = .semitransient
		return popover
	}()
	
	var texture: Texture! {
		didSet {
			levelsView.texture = texture
			nameField        .bind(.value, to: texture, withKeyPath: #keyPath(Texture.name))
			filenameField    .bind(.value, to: texture, withKeyPath: #keyPath(Texture.filename))
			maxSlider        .bind(.value, to: texture, withKeyPath: #keyPath(Texture.mapDomainMax))
			minSlider        .bind(.value, to: texture, withKeyPath: #keyPath(Texture.mapDomainMin))
			inputPathControl .bind(.value, to: texture, withKeyPath: #keyPath(Texture.path))
			outputPathControl.bind(.value, to: texture, withKeyPath: #keyPath(Texture.outputPath))
			maskPathControl  .bind(.value, to: texture, withKeyPath: #keyPath(Texture.maskPath), options: [.nullPlaceholder: "No Mask Set"])
			imageObservation = texture.observe(\.image) { [unowned self] (_, _) in
				self.refreshPreview()
			}
			maskObservation = texture.observe(\.maskImage) { [unowned self] (texture, change) in
				if texture.maskPath != nil, texture.maskImage == nil {
					let alert = NSAlert()
					alert.addButton(withTitle: "Remove Link")
					alert.addButton(withTitle: "Keep Link")
					alert.messageText = "Invalid Mask!"
					alert.informativeText = """
					There was no mask image at the specified location, or the image had the wrong dimensions. (Mask dimensions must match texture dimensions!)
					Would you like to remove the link to the mask location or keep it anyway?
					"""
					alert.alertStyle = .warning
					if alert.runModal() == .alertFirstButtonReturn {
						texture.maskPath = nil
						self.maskPathControl.url = nil // binding doesn't update because we're in a callback it caused
					}
				}
				self.refreshPreview()
			}
			maskPathObservation = texture.observe(\.maskPath, options: .initial) { [unowned self] (texture, _) in
				self.removeMaskButton.isEnabled = texture.maskPath != nil
			}
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

class FilenameHelpViewController: NSViewController, LoadedViewController {
	static let sceneID = NSStoryboard.SceneIdentifier("Filename Help")
}

class MaskHelpViewController: NSViewController, LoadedViewController {
	static let sceneID = NSStoryboard.SceneIdentifier("Mask Help")
}
