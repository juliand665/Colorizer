// Copyright © 2018 Julian Dunskus. All rights reserved.

import Cocoa

class ColorizationViewController: NSViewController, LoadedViewController {
	static let sceneID = NSStoryboard.SceneIdentifier("Colorization")
	
	@IBOutlet weak var nameField: NSTextField!
	@IBOutlet weak var filenameField: NSTextField!
	@IBOutlet weak var lowColorWell: NSColorWell!
	@IBOutlet weak var highColorWell: NSColorWell!
	@IBOutlet weak var gradientView: GradientView!
	
	@IBAction func filenameHelpPressed(_ sender: NSButton) {
		if filenameHelpPopover.isShown {
			filenameHelpPopover.close()
		} else {
			filenameHelpPopover.show(relativeTo: .zero, of: sender, preferredEdge: .maxX)
		}
	}
	
	@IBAction func nameChanged(_ sender: NSTextField) {
		colorization.name = nameField.stringValue
	}
	
	@IBAction func filenameChanged(_ sender: NSTextField) {
		colorization.filename = filenameField.stringValue
	}
	
	@IBAction func colorChanged(_ sender: NSColorWell) {
		colorization.low = lowColorWell.color.color
		colorization.high = highColorWell.color.color
		update()
	}
	
	var filenameHelpPopover: NSPopover!
	
	var colorization: Colorization {
		get {
			return document![colorizationPath]
		}
		set {
			document![colorizationPath] = newValue
		}
	}
	
	var colorizationPath: DocumentPath<Colorization>! {
		didSet {
			document!.observeChanges(as: self, runRightNow: true) { [weak self] in
				self?.update()
			}
		}
	}
	
	override func viewWillAppear() {
		super.viewWillAppear()
		filenameHelpPopover = NSPopover()
		filenameHelpPopover.contentViewController = storyboard!.instantiate(FilenameHelpViewController.self)
		filenameHelpPopover.behavior = .semitransient
		update()
	}
	
	func update() {
		guard isViewLoaded && colorizationPath != nil else { return }
		
		nameField.stringValue = colorization.name
		filenameField.stringValue = colorization.filename
		lowColorWell.color = colorization.low.nsColor
		highColorWell.color = colorization.high.nsColor
		gradientView.leftColor = colorization.low.nsColor
		gradientView.rightColor = colorization.high.nsColor
	}
}

class FilenameHelpViewController: NSViewController, LoadedViewController {
	static let sceneID = NSStoryboard.SceneIdentifier("Filename Help")
}

@IBDesignable
class GradientView: NSView {
	@IBInspectable var leftColor: NSColor! {
		didSet {
			setNeedsDisplay(bounds)
		}
	}
	@IBInspectable var rightColor: NSColor! {
		didSet {
			setNeedsDisplay(bounds)
		}
	}
	
	override func draw(_ dirtyRect: NSRect) {
		let gradient = NSGradient(starting: leftColor, ending: rightColor)!
		gradient.draw(in: bounds, angle: 0)
		
		let edge = NSBezierPath()
		edge.move(to: .zero)
		edge.line(to: NSPoint(x: 0, y: bounds.height))
		edge.line(to: NSPoint(x: bounds.width, y: bounds.height))
		edge.line(to: NSPoint(x: bounds.width, y: 0))
		edge.close()
		edge.lineCapStyle = .squareLineCapStyle
		edge.lineJoinStyle = .miterLineJoinStyle
		
		edge.lineWidth = 12
		#colorLiteral(red: 0.5411764706, green: 0.5411764706, blue: 0.5411764706, alpha: 1).setStroke()
		edge.stroke()
		
		edge.lineWidth = 10
		#colorLiteral(red: 0.937254902, green: 0.937254902, blue: 0.937254902, alpha: 1).setStroke()
		edge.stroke()
		
		edge.lineWidth = 2
		#colorLiteral(red: 0.6862745098, green: 0.6862745098, blue: 0.6862745098, alpha: 1).setStroke()
		edge.stroke()
	}
}
