//
//  SwiftNameOnlyType.swift
//  MGDocIt
//
//  Created by Manav Gabhawala on 16/08/15.
//  Copyright © 2015 Manav Gabhawala. All rights reserved.
//

import Foundation

protocol SwiftNameOnlyType : NameType, SwiftDocumentType
{
	var kind: SwiftDeclarationKind { get }
	
	init(name: String, kind: SwiftDeclarationKind)
}

extension SwiftNameOnlyType
{
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