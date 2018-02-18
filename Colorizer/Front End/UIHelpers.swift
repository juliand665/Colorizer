//  Copyright © 2017 Julian Dunskus. All rights reserved.

import AppKit

extension NSEvent {
	static var isLeftMouseButtonDown: Bool {
		return pressedMouseButtons & 1 != 0
	}
}

protocol Reusable {
	static var reuseID: NSUserInterfaceItemIdentifier { get }
}

extension NSTableView {
	func dequeue<Cell>(_ type: Cell.Type = Cell.self) -> Cell? where Cell: NSTableCellView & Reusable {
		return makeView(withIdentifier: Cell.reuseID, owner: nil) as? Cell
	}
}

extension NSCollectionView {
	func dequeue<Cell>(_ type: Cell.Type = Cell.self, for indexPath: IndexPath) -> Cell? where Cell: NSCollectionViewItem & Reusable {
		return makeItem(withIdentifier: Cell.reuseID, for: indexPath) as? Cell
	}
}

protocol LoadedViewController where Self: NSViewController {
	static var sceneID: NSStoryboard.SceneIdentifier { get }
}

extension NSStoryboard {
	func instantiate<Controller>(_ type: Controller.Type = Controller.self) -> Controller? where Controller: LoadedViewController {
		return instantiateController(withIdentifier: Controller.sceneID) as? Controller
	}
}

/// Creates an `NSError` object with the specified parameters
func error(code: Int = 0, localizedDescription: String? = nil, localizedRecoverySuggestion: String? = nil) -> NSError {
	var userInfo: [String: Any] = [:]
	userInfo[NSLocalizedDescriptionKey] = localizedDescription
	userInfo[NSLocalizedRecoverySuggestionErrorKey] = localizedRecoverySuggestion
	return NSError(domain: "com.juliand665.Colorizer", code: code, userInfo: userInfo)
}

extension CGSize: Comparable {
	/// Returns `true` if `l` is strictly smaller in all dimensions than `r`
	public static func <(l: CGSize, r: CGSize) -> Bool {
		return l.width < r.width && l.height < r.height
	}
}
