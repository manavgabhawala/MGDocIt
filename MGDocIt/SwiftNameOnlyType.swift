//
//  SwiftNameOnlyType.swift
//  MGDocIt
//
//  Created by Manav Gabhawala on 16/08/15.
//  Copyright © 2015 Manav Gabhawala. All rights reserved.
//

import Foundation

class SwiftNameOnlyType : SwiftDocumentType
{
	var documentation: String
	{
		fatalError("Attempting to access documentation from abstract type SwiftNameOnlyType.")
	}
	
	var name: String
	
	var kind: SwiftDeclarationKind
	
	required init(dict: XPCDictionary, map _: SyntaxMap, @noescape stringDelegate _: (start: Int, length: Int) -> String)
	{
		guard let kind = SwiftDocKey.getKind(dict)
		else
		{
			fatalError("No kind found.")
		}
		self.kind = kind
		self.name = SwiftDocKey.getName(dict) ?? ""
	}

}