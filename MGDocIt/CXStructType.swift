//
//  CXStructType.swift
//  MGDocIt
//
//  Created by Manav Gabhawala on 18/08/15.
//  Copyright © 2015 Manav Gabhawala. All rights reserved.
//

import Foundation

private let structKey = "MGCXStruct"
private let structDefaultText = "<#Description of struct #$0#>"

struct CXStruct : CXNameType
{
	var key: String { return structKey }
	var defaultText: String
	{
		return structDefaultText
	}
	var name: String
}