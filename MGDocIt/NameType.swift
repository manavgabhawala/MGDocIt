//
//  NameType.swift
//  MGDocIt
//
//  Created by Manav Gabhawala on 18/08/15.
//  Copyright © 2015 Manav Gabhawala. All rights reserved.
//

import Foundation
protocol NameType : Documentable
{
	/// The name of the document type.
	var name: String { get }
}

extension NameType
{
	var availableTokens : [String: (String, DocumentableType)]
	{
		return ["#$0": ("Name", .String)]
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
		return nil
	}
	
	func boolForToken(token: String) -> Bool?
	{
		return nil
	}
}
