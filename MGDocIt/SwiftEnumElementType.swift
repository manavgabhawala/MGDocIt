//
//  SwiftEnumElementType.swift
//  MGDocIt
//
//  Created by Manav Gabhawala on 16/08/15.
//  Copyright © 2015 Manav Gabhawala. All rights reserved.
//

import Foundation

struct SwiftEnumElement : SwiftDocumentType, Documentable
{
	var key: String { return "MGSwiftEnumElement" }
	var defaultText: String { return "<#Description of #$0 #>" }

	var names : [String]
	var kind = SwiftDeclarationKind.Enumcase
	
	init(dict: XPCDictionary, map: SyntaxMap, @noescape stringDelegate: (start: Int, length: Int) -> String)
	{
		guard kind == SwiftDocKey.getKind(dict), let subs = SwiftDocKey.getSubstructure(dict)
		else
		{
			fatalError("Non enum type \(SwiftDocKey.getKind(dict)) sent to `SwiftEnumElement`")
		}
		names = [String]()
		names.reserveCapacity(subs.count)
		for elem in subs
		{
			guard let subDict = elem as? XPCDictionary
			else
			{
				continue
			}
			guard SwiftDocKey.getKind(subDict) == .Enumelement, let name = SwiftDocKey.getName(subDict)
			else
			{
				continue
			}
			names.append(name)
		}
	}

	var availableTokens: [String: (String, DocumentableType)]
	{
		return ["#$0" : ("Elements", .Array)]
	}
	func stringForToken(token: String) -> String?
	{
		return nil
	}
	
	func arrayForToken(token: String) -> [String]?
	{
		guard token == "#$0"
		else
		{
			return nil
		}
		return names
	}
	
	func boolForToken(token: String) -> Bool?
	{
		return nil
	}
}