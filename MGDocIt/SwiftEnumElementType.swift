//
//  SwiftEnumElementType.swift
//  MGDocIt
//
//  Created by Manav Gabhawala on 16/08/15.
//  Copyright © 2015 Manav Gabhawala. All rights reserved.
//

import Foundation

class SwiftEnumElement : SwiftDocumentType
{
	var documentation: String
	{
		return ""
	}
	
	var names : [String]
	var kind = SwiftDeclarationKind.Enumcase
	
	required init(dict: XPCDictionary, map: SyntaxMap, @noescape stringDelegate: (start: Int, length: Int) -> String)
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
}