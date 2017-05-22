//
//  ViewController.swift
//  Colorizer
//
//  Created by Julian Dunskus on 14.04.17.
//  Copyright © 2017 Julian Dunskus. All rights reserved.
//

import Cocoa

class ViewController: NSViewController {
	
	@IBOutlet weak var texturesTableView: NSTableView!
	
	override func viewDidLoad() {
		super.viewDidLoad()
		
		texturesTableView.sizeLastColumnToFit()
	}
	
	override var representedObject: Any? {
		didSet {
			// Update the view, if already loaded.
			if let colorSet = representedObject as? ColorSetDocument {
				
			}
		}
	}
}
