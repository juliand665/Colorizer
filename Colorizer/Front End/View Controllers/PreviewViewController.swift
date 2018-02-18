// Copyright © 2018 Julian Dunskus. All rights reserved.

import Cocoa

class PreviewViewController: NSViewController, LoadedViewController {
	static let sceneID = NSStoryboard.SceneIdentifier("Preview")
	
	@IBOutlet weak var previewView: NSCollectionView!
	@IBOutlet weak var renderingIndicator: NSProgressIndicator!
	
	var images: [NSImage] = [] {
		didSet {
			previewView.reloadData()
		}
	}
	var queue: DiscardingQueue!
	@objc dynamic var isUpToDate = true {
		didSet {
			if isUpToDate {
				renderingIndicator.stopAnimation(nil)
			} else {
				renderingIndicator.startAnimation(nil)
			}
		}
	}
	
	var currentOperation = 0
	func update(calling block: @escaping () -> [NSImage]) {
		currentOperation += 1
		let op = currentOperation
		isUpToDate = false
		queue.async {
			guard op == self.currentOperation else { return }
			let previews = block()
			guard op == self.currentOperation else { return }
			DispatchQueue.main.async {
				guard op == self.currentOperation else { return }
				self.isUpToDate = true
				self.images = previews
			}
		}
	}
	
	override func viewDidLoad() {
		super.viewDidLoad()
		previewView.register(NSNib(nibNamed: .init("PreviewItem"), bundle: nil), forItemWithIdentifier: PreviewItem.reuseID)
	}
	
	func prepare() {
		queue = DiscardingQueue(label: "Preview")
		images = []
		currentOperation += 1
	}
}

extension PreviewViewController: NSCollectionViewDataSource {
	func collectionView(_ collectionView: NSCollectionView, numberOfItemsInSection section: Int) -> Int {
		return images.count
	}
	
	func collectionView(_ collectionView: NSCollectionView, itemForRepresentedObjectAt indexPath: IndexPath) -> NSCollectionViewItem {
		let item = collectionView.dequeue(PreviewItem.self, for: indexPath)!
		item.bind(.isUpToDate, to: self, withKeyPath: #keyPath(isUpToDate))
		item.imageView!.image = images[indexPath.item]
		return item
	}
}

@objcMembers
class PreviewItem: NSCollectionViewItem, Reusable {
	static let reuseID = NSUserInterfaceItemIdentifier("Preview")
	
	dynamic var isUpToDate = true {
		didSet {
			imageView!.alphaValue = isUpToDate ? 1 : 0.25
		}
	}
}

extension NSBindingName {
	static let isUpToDate = NSBindingName("isUpToDate")
}
