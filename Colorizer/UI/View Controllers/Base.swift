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

extension Window: OnScreen {
	var window: NSWindow? {
		return self
	}
}

extension NSView: OnScreen {}

extension OnScreen {
	var document: ColorSetDocument? {
		return window?.windowController?.document as? ColorSetDocument
	}
	
	var colorSet: ColorSet {
		get {
			return document!.colorSet
		}
		set {
			document!.colorSet = newValue
		}
	}
}

protocol DocumentObserving: OnScreen {
	func startObserving()
	func update()
	func stopObserving()
}

extension DocumentObserving {
	func startObserving() {
		document?.observeChanges(as: self, runRightNow: true) {
			$0.update()
		}
	}
	
	func stopObserving() {
		document?.stopObserving(as: self)
	}
}

// shuts up console messages:
class WindowController: NSWindowController {
	@IBAction func colorizePressed(_ sender: NSButton) {
		(document as! ColorSetDocument).colorSet.colorizeAll()
	}
}
class Window: NSWindow {}
