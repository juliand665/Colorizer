// Copyright © 2018 Julian Dunskus. All rights reserved.

import Cocoa

protocol OnScreen {
	var window: NSWindow? { get }
}

extension NSViewController: OnScreen {
	var window: NSWindow? {
		return view.window
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

// shuts up console messages:
class WindowController: NSWindowController {}
class Window: NSWindow {}
