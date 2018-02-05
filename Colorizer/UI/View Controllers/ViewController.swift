//  Copyright © 2017 Julian Dunskus. All rights reserved.

import Cocoa

class ViewController: NSViewController {
	@IBOutlet weak var sidebarView: NSOutlineView!
	@IBOutlet weak var containerView: NSView!
	
	let headers: [Header] = [.colors, .textures]
	
	var containedViewController: NSViewController? {
		willSet {
			containedViewController?.view.removeFromSuperview()
			containedViewController?.removeFromParentViewController()
		}
		didSet {
			if let new = containedViewController {
				addChildViewController(new)
				containerView.addSubview(new.view)
				new.view.frame = containerView.bounds
				new.view.autoresizingMask = [.width, .height]
			}
		}
	}
	
	var document: ColorSetDocument? {
		return view.window?.windowController?.document as? ColorSetDocument
	}
	
	var colorSet: ColorSet {
		return document!.colorSet
	}
	
	override func viewDidLoad() {
		super.viewDidLoad()
		showHelpViewController()
	}
	
	override func viewDidAppear() {
		super.viewDidAppear()
		sidebarView.expandItem(nil, expandChildren: true) // expands everything
		sidebarView.selectRowIndexes([1], byExtendingSelection: false)
	}
	
	@IBAction func sidebarClicked(_ sender: NSOutlineView) {
		if sidebarView.clickedRow == -1 {
			// because outlineView.deselectAll(sender) doesn't work…
			sidebarView.selectRowIndexes([], byExtendingSelection: false)
		}
	}
	
	@IBAction func addButtonClicked(_ sender: NSButton) {
		let new = Colorization(named: "new", low: #colorLiteral(red: 0, green: 0, blue: 0, alpha: 1).color, high: #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1).color)
		colorSet.colorizations.append(new)
		sidebarView.insertItems(at: [colorSet.colorizations.count - 1],
								inParent: Header.colors,
								withAnimation: .slideUp)
	}
	
	func acceptPNG(at url: URL) {
		let new = Texture(at: url)
		document!.colorSet.textures.append(new)
		sidebarView.insertItems(at: [colorSet.textures.count - 1],
								inParent: Header.textures,
								withAnimation: .slideUp)
	}
	
	func showHelpViewController() {
		containedViewController = storyboard!.instantiate(HelpViewController.self)!
	}
}

extension ViewController: NSOutlineViewDelegate {
	func outlineViewSelectionDidChange(_ notification: Notification) {
		let selection = sidebarView.item(atRow: sidebarView.selectedRow)
		switch selection {
		case let colorization as Colorization:
			let colorViewController = containedViewController as? ColorizationViewController ?? storyboard!.instantiate()!
			colorViewController.colorization = colorization
			containedViewController = colorViewController
		default:
			showHelpViewController()
		}
	}
	
	func outlineView(_ outlineView: NSOutlineView, shouldSelectItem item: Any) -> Bool {
		return !(item is Header)
	}
	
	func outlineView(_ outlineView: NSOutlineView, shouldCollapseItem item: Any) -> Bool {
		return false // items are expanded by default and can never be contracted again
	}
	
	func outlineView(_ outlineView: NSOutlineView, viewFor tableColumn: NSTableColumn?, item: Any) -> NSView? {
		if let header = item as? Header {
			let cell = outlineView.dequeue(HeaderCellView.self)!
			cell.header = header
			return cell
		} else if let colorization = item as? Colorization {
			let cell = outlineView.dequeue(ColorCellView.self)!
			cell.colorization = colorization
			return cell
		} else if let texture = item as? Texture {
			let cell = outlineView.dequeue(TextureCellView.self)!
			cell.texture = texture
			return cell
		}
		fatalError()
	}
}

extension ViewController: NSOutlineViewDataSource {
	func outlineView(_ outlineView: NSOutlineView, numberOfChildrenOfItem item: Any?) -> Int {
		if item == nil {
			return headers.count
		} else if let header = item as? Header {
			return header == .colors ? colorSet.colorizations.count : colorSet.textures.count
		}
		fatalError()
	}
	
	func outlineView(_ outlineView: NSOutlineView, child index: Int, ofItem item: Any?) -> Any {
		if item == nil {
			return headers[index]
		} else if let header = item as? Header {
			return header == .colors ? colorSet.colorizations[index] : colorSet.textures[index]
		}
		fatalError()
	}
	
	func outlineView(_ outlineView: NSOutlineView, isItemExpandable item: Any) -> Bool {
		return item is Header
	}
	
	func outlineView(_ outlineView: NSOutlineView, objectValueFor tableColumn: NSTableColumn?, byItem item: Any?) -> Any? {
		return 42
	}
}

enum Header: String {
	case colors
	case textures
}

// shuts up console messages:
class WindowController: NSWindowController {}
class Window: NSWindow {}
