//
//  NameAndInheritedType.swift
//  MGDocIt
//
//  Created by Manav Gabhawala on 18/08/15.
//  Copyright © 2015 Manav Gabhawala. All rights reserved.
//

import Foundation

protocol NameAndInheritedType: Documentable
{
	var name: String { get }
	var inheritedTypes: [String] { get }
}
extension NameAndInheritedType
{
	var availableTokens : [String: (String, DocumentableType)]
	{
		return ["#$0": ("Name", .String), "#$1": ("Inherited Types", .Array)]
	}
	
	func stringForToken(token: String) -> String?
	{
		guard token == "#$0"
			else
		{
			return nil
		}
		return name
	}
	
	func arrayForToken(token: String) -> [String]?
	{
		guard token == "#$1"
			else
		{
			return nil
		}
		return inheritedTypes
	}
	
	func boolForToken(token: String) -> Bool?
	{
		return nil
	}
}