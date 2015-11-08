//
//  AdvancedPreferencesController.swift
//  MGDocIt
//
//  Created by Manav Gabhawala on 11/8/15.
//  Copyright © 2015 Manav Gabhawala. All rights reserved.
//

import Cocoa

private let documentableTypes : [Documentable] = []

class AdvancedPreferencesController: NSViewController {

	@IBOutlet var tableView: NSTableView!
	@IBOutlet var textView: NSTextView!
	
	
	
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do view setup here.
    }
    
}
extension AdvancedPreferencesController : NSTableViewDataSource, NSTableViewDelegate
{
	func numberOfRowsInTableView(tableView: NSTableView) -> Int
	{
		return 0
	}
	func tableView(tableView: NSTableView, viewForTableColumn tableColumn: NSTableColumn?, row: Int) -> NSView?
	{
		return nil
	}
}