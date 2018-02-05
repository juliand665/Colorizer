// Copyright © 2018 Julian Dunskus. All rights reserved.

import Cocoa

class HeaderCellView: NSTableCellView, LoadedTableCell {
	static let reuseID = NSUserInterfaceItemIdentifier("Header Cell")
	
	@IBOutlet weak var titleLabel: NSTextField!
	
	var header: Header! {
		didSet {
			titleLabel.stringValue = header.rawValue.uppercased()
		}
	}
}
