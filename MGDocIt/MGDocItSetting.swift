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
private let prefixStringKey = "MGPrefixString"
private let beginningStringKey = "MGBeginningString"
private let endingStringKey = "MGEndingString"

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
	
	class var linePrefix : String
	{
		get
		{
			guard let prefix = defaults.stringForKey(prefixStringKey)
			else
			{
				self.linePrefix = "/// "
				return "/// "
			}
			return prefix
		}
		set
		{
			defaults.setObject(newValue, forKey: prefixStringKey)
		}
	}
	
	class var beginningDoc : String
	{
		get
		{
			guard let beginning = defaults.stringForKey(beginningStringKey)
			else
			{
				self.beginningDoc = ""
				return ""
			}
			return beginning
		}
		set
		{
			defaults.setObject(newValue, forKey: beginningStringKey)
		}
	}
	class var endingDoc: String
	{
		get
		{
			guard let ending = defaults.stringForKey(endingStringKey)
			else
			{
				self.endingDoc = ""
				return ""
			}
			return ending
		}
		set
		{
			defaults.setObject(newValue, forKey: endingStringKey)
		}
	}
	
	class func getCustomDocumentationForKey(key: String, defaultText: String) -> String
	{
		guard let docText = defaults.stringForKey(key)
		else
		{
			return defaultText
		}
		return docText
	}
	class func setCustomDocumentationForKey(key: String, newDocText doc: String)
	{
		defaults.setObject(doc, forKey: key)
	}
}
