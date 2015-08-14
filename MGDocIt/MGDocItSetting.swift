//
//  MGDocItSetting.swift
//  MGDocIt
//
//  Created by Manav Gabhawala on 14/08/15.
//  Copyright © 2015 Manav Gabhawala. All rights reserved.
//

import Foundation

private let defaults = NSUserDefaults.standardUserDefaults()

private let triggerStringKey = "MGTriggerString"


@objc class MGDocItSetting: NSObject
{
	class var triggerString : String
	{
		get
		{
			guard let trigger = defaults.stringForKey(triggerStringKey) where !trigger.isEmpty
			else
			{
				self.triggerString = "///"
				return "///"
			}
			return trigger
		}
		set
		{
			guard newValue.characters.count > 0
			else
			{
				return
			}
			defaults.setObject(newValue, forKey: triggerStringKey)
		}
	}
}
