// Copyright © 2018 Julian Dunskus. All rights reserved.

import Cocoa

class ColorizationViewController: NSViewController, LoadedViewController, DocumentObserving {
	static let sceneID = NSStoryboard.SceneIdentifier("Colorization")
	
	@IBOutlet weak var nameField: NSTextField!
	@IBOutlet weak var filenameField: NSTextField!
	@IBOutlet weak var lowColorWell: NSColorWell!
	@IBOutlet weak var highColorWell: NSColorWell!
	@IBOutlet weak var gradientView: GradientView!
	
	@IBAction func filenameHelpPressed(_ sender: NSButton) {
		if filenameHelpPopover.isShown {
			filenameHelpPopover.close()
		} else {
			filenameHelpPopover.show(relativeTo: .zero, of: sender, preferredEdge: .minY)
		}
	}
	
	@IBAction func nameChanged(_ sender: NSTextField) {
		colorization.name ∂= nameField.stringValue
	}
	
	@IBAction func filenameChanged(_ sender: NSTextField) {
		colorization.filename ∂= filenameField.stringValue
	}
	
	@IBAction func colorChanged(_ sender: NSColorWell) {
		colorization.low ∂= lowColorWell.color.color
		colorization.high ∂= highColorWell.color.color
	}
	
	var filenameHelpPopover: NSPopover!
	var colorizationPath: DocumentPath<Colorization>!
	var colorization: Colorization {
		get {
			return document![colorizationPath]
		}
		set {
			document![colorizationPath] = newValue
		}
	}
	
	override func viewDidAppear() {
		super.viewDidAppear()
		filenameHelpPopover = NSPopover()
		filenameHelpPopover.contentViewController = storyboard!.instantiate(FilenameHelpViewController.self)
		filenameHelpPopover.behavior = .semitransient
		filenameField.stringValue = colorization.filename
		lowColorWell.color = colorization.low.nsColor
		highColorWell.color = colorization.high.nsColor

		startObserving()
	}
	
	func update() {
		nameField.stringValue = colorization.name
		gradientView.leftColor = colorization.low.nsColor
		gradientView.rightColor = colorization.high.nsColor
	}
}

class FilenameHelpViewController: NSViewController, LoadedViewController {
	static let sceneID = NSStoryboard.SceneIdentifier("Filename Help")
}
