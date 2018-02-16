// Copyright © 2018 Julian Dunskus. All rights reserved.

import Cocoa

protocol OnScreen: AnyObject {
	var window: NSWindow? { get }
}

extension NSViewController: OnScreen {
	var window: NSWindow? {
		return view.window
	}
}

extension NSWindow: OnScreen {
	var window: NSWindow? {
		return self
	}
}

extension NSWindowController: OnScreen {}

extension NSView: OnScreen {}

extension OnScreen {
	var colorSet: ColorSet {
		return (window!.windowController!.document as! ColorSetDocument).colorSet
	}
}

class WindowController: NSWindowController {
	@IBAction func colorizePressed(_ sender: NSButton) {
		colorSet.colorizeAll()
	}
	
	@IBAction func reloadPressed(_ sender: NSButton) {
		colorSet.reloadImages()
	}
}

// shuts up console messages:
class Window: NSWindow {}
