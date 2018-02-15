//  Copyright © 2017 Julian Dunskus. All rights reserved.

import Cocoa

class MainViewController: NSViewController {
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
		document!.colorSet.colorizations.append(new)
		sidebarView.insertItems(at: [colorSet.colorizations.count - 1],
								inParent: Header.colors,
								withAnimation: .slideUp)
	}
	
	@IBAction func removeButtonClicked(_ sender: NSButton) {
		let selection = sidebarView.selectedRowIndexes
		(containedViewController as! DocumentObserving).stopObserving()
		// deselect all
		sidebarView.selectRowIndexes([], byExtendingSelection: false)
		// make a copy to commit changes all at once
		var copy = document!.colorSet
		// traverse backwards so removing items won't fuck up indices of later items
		for row in selection.sorted().reversed() {
			let (header, index) = sidebarView.item(atRow: row) as! (Header, Int)
			switch header {
			case .colors:
				copy.colorizations.remove(at: index)
			case .textures:
				copy.textures.remove(at: index)
			}
			(sidebarView.view(atColumn: 0, row: row, makeIfNecessary: false) as! DocumentObserving).stopObserving()
			sidebarView.removeItems(at: [index], inParent: header, withAnimation: .slideLeft)
		}
		document!.colorSet = copy
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
	
	enum Header: String {
		case colors
		case textures
	}
}

extension MainViewController: NSOutlineViewDelegate {
	func outlineViewSelectionDidChange(_ notification: Notification) {
		let selection = sidebarView.item(atRow: sidebarView.selectedRow)
		switch selection {
		case (.colors, let index) as (Header, Int):
			let viewController = containedViewController as? ColorizationViewController ?? storyboard!.instantiate()!
			viewController.colorizationPath = \.colorSet.colorizations[index] as DocumentPath<Colorization>
			containedViewController = viewController
		case (.textures, let index) as (Header, Int):
			let viewController = containedViewController as? TextureViewController ?? storyboard!.instantiate()!
			viewController.texturePath = \.colorSet.textures[index] as DocumentPath<Texture>
			containedViewController = viewController
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
		switch item {
		case let header as Header:
			let cell = outlineView.dequeue(HeaderCellView.self)!
			cell.header = header
			return cell
		case (.colors, let index) as (Header, Int):
			let cell = outlineView.dequeue(ColorizationCellView.self)!
			cell.colorizationPath = \.colorSet.colorizations[index] as DocumentPath<Colorization> // TODO jfc
			return cell
		case (.textures, let index) as (Header, Int):
			let cell = outlineView.dequeue(TextureCellView.self)!
			cell.texturePath = \.colorSet.textures[index] as DocumentPath<Texture>
			return cell
		default:
			fatalError()
		}
	}
}

extension MainViewController: NSOutlineViewDataSource {
	func outlineView(_ outlineView: NSOutlineView, numberOfChildrenOfItem item: Any?) -> Int {
		switch item {
		case nil:
			return headers.count
		case .colors as Header:
			return colorSet.colorizations.count
		case .textures as Header:
			return colorSet.textures.count
		default:
			fatalError()
		}
	}
	
	func outlineView(_ outlineView: NSOutlineView, child index: Int, ofItem item: Any?) -> Any {
		switch item {
		case nil:
			return headers[index]
		case let header as Header:
			return (header, index)
		default:
			fatalError()
		}
	}
	
	func outlineView(_ outlineView: NSOutlineView, isItemExpandable item: Any) -> Bool {
		return item is Header
	}
	
	func outlineView(_ outlineView: NSOutlineView, objectValueFor tableColumn: NSTableColumn?, byItem item: Any?) -> Any? {
		return 42
	}
}
