// Copyright © 2018 Julian Dunskus. All rights reserved.

import Cocoa

class TextureCellView: NSTableCellView, Reusable {
	static let reuseID = NSUserInterfaceItemIdentifier("Texture Cell")
	
	@IBOutlet weak var iconView: NSImageView!
	@IBOutlet weak var nameLabel: NSTextField!
	
	var texture: Texture! {
		didSet {
			nameLabel.bind(.value, to: texture, withKeyPath: #keyPath(Texture.name))
			iconView.bind(.image, to: texture, withKeyPath: #keyPath(Texture.image))
		}
	}
}
