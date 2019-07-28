// Copyright © 2018 Julian Dunskus. All rights reserved.

import Cocoa

class TextureViewController: NSViewController, LoadedViewController {
	static var sceneID = "Texture"
	
	@IBOutlet var nameField: NSTextField!
	@IBOutlet var filenameField: NSTextField!
	@IBOutlet var inputPathControl: NSPathControl!
	@IBOutlet var outputPathControl: NSPathControl!
	@IBOutlet var maskPathControl: NSPathControl!
	@IBOutlet var removeMaskButton: NSButton!
	@IBOutlet var levelsView: TextureLevelsView!
	@IBOutlet var maxSlider: NSSlider!
	@IBOutlet var minSlider: NSSlider!
	@IBOutlet var maxField: NSTextField!
	@IBOutlet var minField: NSTextField!
	@IBOutlet var copyBoundsButton: NSButton!
	@IBOutlet var pasteBoundsButton: NSButton!
	@IBOutlet var previewView: NSView!
	
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
	
	@IBAction func copyBounds(_ sender: Any) {
		NSPasteboard.general.clearContents()
		NSPasteboard.general.setString("\(texture.mapDomainMin)\t\(texture.mapDomainMax)", forType: .tabularText)
	}
	
	@IBAction func pasteBounds(_ sender: Any) {
		guard
			let strings = NSPasteboard.general.string(forType: .tabularText)?.components(separatedBy: "\t"),
			strings.count == 2,
			let min = Double(strings[0]),
			let max = Double(strings[1])
			else {
				let alert = NSAlert()
				alert.alertStyle = .warning
				alert.messageText = "Could not read bounds from clipboard!"
				alert.informativeText = "Please ensure you copied data in the correct format—the easiest way is to use the copy button just to the left of the one you just pressed."
				alert.runModal()
				return
		}
		
		texture.mapDomainMin = CGFloat(min)
		texture.mapDomainMax = CGFloat(max)
		refreshPreview()
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
			nameField        .bind(.value, to: texture!, withKeyPath: #keyPath(Texture.name))
			filenameField    .bind(.value, to: texture!, withKeyPath: #keyPath(Texture.filename))
			maxSlider        .bind(.value, to: texture!, withKeyPath: #keyPath(Texture.mapDomainMax))
			minSlider        .bind(.value, to: texture!, withKeyPath: #keyPath(Texture.mapDomainMin))
			maxField         .bind(.value, to: texture!, withKeyPath: #keyPath(Texture.mapDomainMaxOptional))
			minField         .bind(.value, to: texture!, withKeyPath: #keyPath(Texture.mapDomainMinOptional))
			inputPathControl .bind(.value, to: texture!, withKeyPath: #keyPath(Texture.path))
			outputPathControl.bind(.value, to: texture!, withKeyPath: #keyPath(Texture.outputPath))
			maskPathControl  .bind(.value, to: texture!, withKeyPath: #keyPath(Texture.maskPath), options: [.nullPlaceholder: "No Mask Set"])
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
		addChild(previewViewController)
		previewView.addSubview(previewViewController.view)
		previewViewController.view.frame = previewView.bounds
		previewViewController.view.autoresizingMask = [.width, .height]
	}
}

class FilenameHelpViewController: NSViewController, LoadedViewController {
	static let sceneID = "Filename Help"
}

class MaskHelpViewController: NSViewController, LoadedViewController {
	static let sceneID = "Mask Help"
}
