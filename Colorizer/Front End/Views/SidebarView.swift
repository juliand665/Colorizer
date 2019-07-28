// Copyright © 2018 Julian Dunskus. All rights reserved.

import Cocoa

class SidebarView: NSOutlineView {
	override func frameOfOutlineCell(atRow row: Int) -> NSRect {
		return .zero // no disclosure triangles
	}
	
	override func awakeFromNib() {
		super.awakeFromNib()
		registerForDraggedTypes([.filenames])
	}
	
	func pngURL(from info: NSDraggingInfo) -> URL? {
		guard let path = info.draggingPasteboard.filePath
			else { return nil }
		let url = URL(fileURLWithPath: path)
		guard url.pathExtension == "png"
			else { return nil }
		return url
	}
	
	override func draggingEntered(_ info: NSDraggingInfo) -> NSDragOperation {
		return draggingUpdated(info)
	}
	
	override func draggingUpdated(_ info: NSDraggingInfo) -> NSDragOperation {
		return pngURL(from: info) != nil ? .copy : []
	}
	
	override func performDragOperation(_ info: NSDraggingInfo) -> Bool {
		guard let url = pngURL(from: info)
			else { return false }
		let controller = window!.contentViewController! as! MainViewController
		controller.acceptPNG(at: url)
		return true
	}
}

extension NSPasteboard {
	var filePath: String? {
		return (propertyList(forType: .filenames) as? NSArray)?.firstObject as? String
	}
}

extension NSPasteboard.PasteboardType {
	static let filenames = NSPasteboard.PasteboardType("NSFilenamesPboardType") // eww
}
