//
//  ObjectiveCVarType.swift
//  MGDocIt
//
//  Created by Manav Gabhawala on 18/08/15.
//  Copyright © 2015 Manav Gabhawala. All rights reserved.
//

import Foundation

private let varKey = "MGObjcVar"
private let varDefaultText = "<#Description of variable #$0#>"

struct ObjectiveCVar : CXNameType
{
	var key: String { return varKey }
	var defaultText: String
	{
		return varDefaultText
	}
	var name: String
}