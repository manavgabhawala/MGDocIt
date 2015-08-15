//
//  SwiftNameAndInheritedType.swift
//  MGDocIt
//
//  Created by Manav Gabhawala on 16/08/15.
//  Copyright © 2015 Manav Gabhawala. All rights reserved.
//

import Foundation

class SwiftNameAndInheritedType : SwiftNameOnlyType
{
	var inheritedTypes : [String]
	required init(dict: XPCDictionary, map: SyntaxMap, @noescape stringDelegate: (start: Int, length: Int) -> String)
	{
		inheritedTypes = SwiftDocKey.getInheritedTypes(dict) ?? []
		super.init(dict: dict, map: map, stringDelegate: stringDelegate)
	}

}