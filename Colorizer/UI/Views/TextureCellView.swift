// Copyright © 2018 Julian Dunskus. All rights reserved.

import Cocoa

class TextureCellView: NSTableCellView, LoadedTableCell {
	static let reuseID = NSUserInterfaceItemIdentifier("Texture Cell")
	
	@IBOutlet weak var iconView: NSImageView!
	@IBOutlet weak var nameLabel: NSTextField!
	
	@IBAction func nameEdited(_ sender: NSTextField) {
		document![texturePath].name = nameLabel.stringValue
	}
	
	var texturePath: DocumentPath<Texture>! {
		didSet {
			document!.observeChanges(as: self, runRightNow: true) { [weak self] in
				self?.update()
			}
		}
	}
	
	func update() { 
		let texture = document![texturePath]
		nameLabel.stringValue = texture.name
		iconView.image = texture.image
	}
}
