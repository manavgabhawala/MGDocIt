//
//  SwiftNameOnlyType.swift
//  MGDocIt
//
//  Created by Manav Gabhawala on 16/08/15.
//  Copyright © 2015 Manav Gabhawala. All rights reserved.
//

import Foundation

protocol SwiftNameOnlyType : SwiftDocumentType, Documentable
{
	var kind: SwiftDeclarationKind { get }
	var name: String { get }
	
	init(name: String, kind: SwiftDeclarationKind)
}

extension SwiftNameOnlyType
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
	
	init(dict: XPCDictionary, map _: SyntaxMap, @noescape stringDelegate _: (start: Int, length: Int) -> String)
	{
		guard let kind = SwiftDocKey.getKind(dict)
		else
		{
			fatalError("No kind found.")
		}
		self.init(name: SwiftDocKey.getName(dict) ?? "", kind: kind)
	}
}