//
//  GeneralPreferencesController.swift
//  MGDocIt
//
//  Created by Manav Gabhawala on 11/8/15.
//  Copyright © 2015 Manav Gabhawala. All rights reserved.
//

import Cocoa

class GeneralPreferencesController: NSViewController {

	@IBOutlet var triggerString: NSTextField!
	@IBOutlet var linePrefixButtons : NSMatrix!
	@IBOutlet var prefixButtons : NSMatrix!
	@IBOutlet var suffixButtons: NSMatrix!

	
    override func viewDidLoad()
	{
        super.viewDidLoad()
        // Do view setup here.
		triggerString.delegate = self
		linePrefixButtons.target = self
		linePrefixButtons.action = "linePrefixClick:"
		prefixButtons.target = self
		prefixButtons.action = "prefixButtonClick:"
		suffixButtons.target = self
		suffixButtons.action = "suffixButtonClick:"
		
    }
	override func viewDidAppear()
	{
		super.viewDidAppear()
		triggerString.stringValue = MGDocItSetting.triggerString
		updateLinePrefix()
	}
	
	func updateLinePrefix()
	{
		for cell in linePrefixButtons.cells
		{
			cell.state = 0
		}
		switch MGDocItSetting.linePrefix
		{
		case "/// ":
			linePrefixButtons.cells[0].state = 1
		case "* ":
			linePrefixButtons.cells[1].state = 1
		case "":
			linePrefixButtons.cells[2].state = 1
		default:
			linePrefixButtons.cells[0].state = 1
			MGDocItSetting.linePrefix = "/// "
		}
	}
	
	func linePrefixClick(sender: NSMatrix)
	{
		switch sender.selectedRow
		{
		case 0:
			MGDocItSetting.linePrefix = "/// "
		case 1:
			MGDocItSetting.linePrefix = "* "
		case 2:
			MGDocItSetting.linePrefix = ""
		default:
			fatalError("Out of bounds")
		}
		updateLinePrefix()
	}
	
	func prefixButtonClick(sender: NSMatrix)
	{
		
	}
	func suffixButtonClick(sender: NSMatrix)
	{
		
	}
    
}
extension GeneralPreferencesController : NSTextFieldDelegate
{
	override func controlTextDidChange(obj: NSNotification)
	{
		guard obj.object as? NSTextField == triggerString
		else
		{
			return
		}
		MGDocItSetting.triggerString = triggerString.stringValue
	}
}