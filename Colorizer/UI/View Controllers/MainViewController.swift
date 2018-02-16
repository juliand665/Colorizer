//  Copyright © 2017 Julian Dunskus. All rights reserved.

import Cocoa

class MainViewController: NSViewController {
	@IBOutlet weak var sidebarView: NSOutlineView!
	@IBOutlet weak var containerView: NSView!
	@IBOutlet weak var removeButton: NSButton!
	
	let headers: [Header] = [.colorizations, .textures]
	
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
		let new = Colorization(named: "untitled", low: #colorLiteral(red: 0, green: 0, blue: 0, alpha: 1), high: #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1))
		colorSet.colorizations.append(new)
		sidebarView.insertItems(at: [colorSet.colorizations.count - 1],
								inParent: Header.colorizations)
	}
	
	@IBAction func removeButtonClicked(_ sender: NSButton) {
		guard let item = sidebarView.item(atRow: sidebarView.selectedRow)
			else { return }
		switch item {
		case let colorization as Colorization:
			colorSet.colorizations.remove(colorization)
		case let texture as Texture:
			colorSet.textures.remove(texture)
		default:
			fatalError()
		}
		sidebarView.removeItems(at: [sidebarView.childIndex(forItem: item)],
								inParent: sidebarView.parent(forItem: item),
								withAnimation: .slideLeft)
	}
	
	func acceptPNG(at url: URL) {
		let new = Texture(at: url)
		colorSet.textures.append(new)
		sidebarView.insertItems(at: [colorSet.textures.count - 1],
								inParent: Header.textures)
	}
	
	func showHelpViewController() {
		containedViewController = containedViewController as? HelpViewController ?? storyboard!.instantiate()!
	}
	
	enum Header: String {
		case colorizations
		case textures
	}
}

extension MainViewController: NSOutlineViewDelegate {
	func outlineViewSelectionDidChange(_ notification: Notification) {
		let selection = sidebarView.item(atRow: sidebarView.selectedRow)
		switch selection {
		case let colorization as Colorization:
			let viewController = containedViewController as? ColorizationViewController ?? storyboard!.instantiate()!
			containedViewController = viewController
			viewController.colorization = colorization
		case let texture as Texture:
			let viewController = containedViewController as? TextureViewController ?? storyboard!.instantiate()!
			containedViewController = viewController
			viewController.texture = texture
		default:
			showHelpViewController()
		}
		removeButton.isEnabled = selection != nil
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
		case let colorization as Colorization:
			let cell = outlineView.dequeue(ColorizationCellView.self)!
			cell.colorization = colorization
			return cell
		case let texture as Texture:
			let cell = outlineView.dequeue(TextureCellView.self)!
			cell.texture = texture
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
		case .colorizations as Header:
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
		case .colorizations as Header:
			return colorSet.colorizations[index]
		case .textures as Header:
			return colorSet.textures[index]
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
