// Copyright © 2018 Julian Dunskus. All rights reserved.

import Cocoa

class ColorizationViewController: NSViewController, LoadedViewController {
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
	
	lazy var filenameHelpPopover: NSPopover = {
		let popover = NSPopover()
		popover.contentViewController = storyboard!.instantiate(FilenameHelpViewController.self)
		popover.behavior = .semitransient
		return popover
	}()
	var colorization: Colorization! {
		didSet {
			nameField.bind(.value, to: colorization, withKeyPath: #keyPath(Colorization.name))
			filenameField.bind(.value, to: colorization, withKeyPath: #keyPath(Colorization.filename))
			lowColorWell.bind(.value, to: colorization, withKeyPath: #keyPath(Colorization.low))
			highColorWell.bind(.value, to: colorization, withKeyPath: #keyPath(Colorization.high))
			gradientView.bind(.leftColor, to: colorization, withKeyPath: #keyPath(Colorization.low))
			gradientView.bind(.rightColor, to: colorization, withKeyPath: #keyPath(Colorization.high))
		}
	}
}

class FilenameHelpViewController: NSViewController, LoadedViewController {
	static let sceneID = NSStoryboard.SceneIdentifier("Filename Help")
}
