// Copyright © 2018 Julian Dunskus. All rights reserved.

import Cocoa

class TextureCellView: NSTableCellView, LoadedTableCell, DocumentObserving {
	static let reuseID = NSUserInterfaceItemIdentifier("Texture Cell")
	
	@IBOutlet weak var iconView: NSImageView!
	@IBOutlet weak var nameLabel: NSTextField!
	
	@IBAction func nameEdited(_ sender: NSTextField) {
		document![texturePath].name ∂= nameLabel.stringValue
	}
	
	var texturePath: DocumentPath<Texture>!
	
	override func viewDidMoveToWindow() {
		super.viewDidMoveToWindow()
		startObserving()
	}
	
	func update() { 
		let texture = document![texturePath]
		nameLabel.stringValue = texture.name
		iconView.image = texture.image
	}
}
