//
//  PreferencesController.swift
//  MGDocIt
//
//  Created by Manav Gabhawala on 11/7/15.
//  Copyright © 2015 Manav Gabhawala. All rights reserved.
//

import Cocoa

enum PreferencePaneTabs : String
{
	case GeneralPreferences = "GeneralPreferencesIdentifier"
	case AdvancedPreferences = "AdvancedPreferencesIdentifier"
	case SupportPreferences = "SupportPreferencesIdentifier"
	func makeToolbarItem(target: AnyObject) -> NSToolbarItem
	{
		let item = NSToolbarItem(itemIdentifier: rawValue)
		switch (self)
		{
		case .GeneralPreferences:
			item.image = NSImage(named: NSImageNamePreferencesGeneral)
			item.label = "General"
			item.target = target
			item.action = "generalButtonPressed:"
		case .AdvancedPreferences:
			item.image = NSImage(named: NSImageNameAdvanced)
			item.label = "Advanced"
			item.target = target
			item.action = "advancedButtonPressed:"
			break
		case .SupportPreferences:
			item.image = NSBundle(forClass: SupportViewController.self).imageForResource("Support")
			item.label = "Support"
			item.target = target
			item.action = "supportButtonPressed:"
		}
		return item
	}
	static func toArray() -> [PreferencePaneTabs]
	{
		return [.GeneralPreferences, .AdvancedPreferences, .SupportPreferences]
	}
	static func order() -> [String]
	{
		return [NSToolbarFlexibleSpaceItemIdentifier, PreferencePaneTabs.GeneralPreferences.rawValue, PreferencePaneTabs.AdvancedPreferences.rawValue, SupportPreferences.rawValue, NSToolbarFlexibleSpaceItemIdentifier]
	}
}


class PreferencesController: NSWindowController {

	let generalPreferences: GeneralPreferencesController = GeneralPreferencesController(nibName: "GeneralPreferencesController", bundle: NSBundle(forClass: GeneralPreferencesController.self))!
	let advancedPreferences: AdvancedPreferencesController = AdvancedPreferencesController(nibName: "AdvancedPreferencesController", bundle: NSBundle(forClass: AdvancedPreferencesController.self))!
	let supportPreferences: SupportViewController = SupportViewController(nibName: "SupportViewController", bundle: NSBundle(forClass: SupportViewController.self))!

	var current : PreferencePaneTabs?
	
	var currentController: NSViewController?
	{
		guard let current = current else { return nil }
		switch current
		{
		case .GeneralPreferences:
			return generalPreferences
		case .AdvancedPreferences:
			return advancedPreferences
		case .SupportPreferences:
			return supportPreferences
		}
	}
	
	override func windowDidLoad()
	{
        super.windowDidLoad()
		let toolbar = NSToolbar(identifier: "PreferencesToolbar")
		toolbar.delegate = self
		toolbar.allowsUserCustomization = false
		toolbar.selectedItemIdentifier = PreferencePaneTabs.GeneralPreferences.rawValue
		window?.toolbar = toolbar
		let item = PreferencePaneTabs.GeneralPreferences.makeToolbarItem(self)
		generalButtonPressed(item)

    }
    
}
extension PreferencesController
{
	func generalButtonPressed(item: NSToolbarItem)
	{
		genericButtonPress(item, controller: generalPreferences, .GeneralPreferences)
	}
	func advancedButtonPressed(item: NSToolbarItem)
	{
		genericButtonPress(item, controller: advancedPreferences, .AdvancedPreferences)
	}
	func supportButtonPressed(item: NSToolbarItem)
	{
		genericButtonPress(item, controller: supportPreferences, .SupportPreferences)
	}
	func genericButtonPress(item: NSToolbarItem, controller: NSViewController, _ newType: PreferencePaneTabs)
	{
		window?.title = item.label
		guard (currentController.dynamicType != controller.dynamicType)
			else { return }
		window?.contentView!.subviews.forEach { $0.removeFromSuperview() }
		current = newType
		updateWindowView()
	}
	func updateWindowView()
	{
		guard let window = window
		else { return }
		let view = currentController!.view
		window.contentView!.addSubview(view)
		let heightDifference = view.frame.height - window.contentView!.frame.height
		let widthDifference = view.frame.width - window.contentView!.frame.width
		currentController!.view.frame.origin = CGPoint(x: 0, y: -heightDifference)
		var frame = window.frame
		frame.size.width += widthDifference
		frame.size.height += heightDifference
		frame.origin.y -= heightDifference
		
		window.maxSize = frame.size
		window.minSize = frame.size
		window.setFrame(frame, display: true, animate: true)
		currentController!.view.frame.origin = CGPointZero
	}
}
extension PreferencesController: NSToolbarDelegate
{
	func toolbarSelectableItemIdentifiers(toolbar: NSToolbar) -> [String]
	{
		return PreferencePaneTabs.toArray().map { $0.rawValue }
	}
	func toolbarDefaultItemIdentifiers(toolbar: NSToolbar) -> [String]
	{
		return PreferencePaneTabs.order()
	}
	func toolbarAllowedItemIdentifiers(toolbar: NSToolbar) -> [String]
	{
		return PreferencePaneTabs.order()
	}
	func toolbar(toolbar: NSToolbar, itemForItemIdentifier itemIdentifier: String, willBeInsertedIntoToolbar flag: Bool) -> NSToolbarItem?
	{
		if let tab = PreferencePaneTabs(rawValue: itemIdentifier)
		{
			return tab.makeToolbarItem(self)
		}
		return nil
	}
}

