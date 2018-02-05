// Copyright © 2018 Julian Dunskus. All rights reserved.

import Cocoa

class TextureCellView: NSTableCellView, LoadedTableCell {
	static let reuseID = NSUserInterfaceItemIdentifier("Texture Cell")
	
	@IBOutlet weak var iconView: NSImageView!
	@IBOutlet weak var nameLabel: NSTextField!
	
	var texture: Texture! {
		didSet {
			nameLabel.stringValue = texture.name
			iconView.image = texture.image
		}
	}
}
